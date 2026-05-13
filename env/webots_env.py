from typing import List, Optional

import numpy as np
import cv2
from vehicle import Driver

TIME_STEP       = 10      # ms — matches basicTimeStep in city.wbt
MAX_STEER       = 0.5     # radians — max steering angle
MAX_SPEED       = 50      # km/h — Driver.setCruisingSpeed takes km/h

LIDAR_OUT_SIZE = 512

# Yellow line HSV bounds — tune against your world's colour
YELLOW_LO = np.array([18,  80,  80], dtype=np.uint8)
YELLOW_HI = np.array([35, 255, 255], dtype=np.uint8)


class WebotsEnv:
    """
    Thin wrapper around the City demo car's Webots devices.

      - Enable and read sensors (camera, LiDAR, touch)
      - Write steering and throttle commands (Ackermann drive)
      - Reset simulation state via Supervisor
      - Expose raw physical quantities (speed, alignment angle)
      - Track episode-level metrics (distance travelled, lap completion,
        near-misses) for use by the Gym wrapper.
    """

    def __init__(
        self,
        near_miss_threshold: float = 1.0,
        collision_threshold: float = 0.3,
        lap_departure_distance: float = 20.0,
        lap_return_distance: float = 5.0,
    ):
        """
        Parameters
        ----------
        near_miss_threshold : float
            LiDAR distance (m) below which a step counts as a near-miss
            (but not a collision). A near-miss is a min-lidar reading in
            (collision_threshold, near_miss_threshold].
        collision_threshold : float
            LiDAR distance (m) used only to separate near-miss from crash
            in _update_tracking. Collision detection itself uses the touch sensor.
        lap_departure_distance : float
            Metres the car must travel away from its spawn before the
            lap-completion detector becomes armed.
        lap_return_distance : float
            Metres within which, after having departed, a return to the
            spawn counts as completing one lap.
        """
        self.driver = Driver()
        self._first_reset = True

        # ── Camera ────────────────────────────────────────────────
        self.camera = self.driver.getDevice("camera")
        self.camera.enable(TIME_STEP)
        self.cam_w = self.camera.getWidth()
        self.cam_h = self.camera.getHeight()

        # ── LiDAR ─────────────────────────────────────────────────
        self.lidar = self.driver.getDevice("lidar")
        self.lidar.enable(TIME_STEP)
        self.lidar_size = LIDAR_OUT_SIZE

        # ── Steering motors ───────────────────────────────────────
        self.left_steer  = self.driver.getDevice("left_steer")
        self.right_steer = self.driver.getDevice("right_steer")
        for s in (self.left_steer, self.right_steer):
            s.setPosition(0.0)

        self.left_wheel  = self.driver.getDevice("left_front_wheel")
        self.right_wheel = self.driver.getDevice("right_front_wheel")
        for w in (self.left_wheel, self.right_wheel):
            w.setPosition(float("inf"))  # velocity-control mode
            w.setVelocity(0.0)

        # ── Supervisor: needed for teleport-reset ─────────────────
        self.driver_node = self.driver.getSelf()
        self._init_translation = list(
            self.driver_node.getField("translation").getSFVec3f()
        )
        self._init_rotation = list(
            self.driver_node.getField("rotation").getSFRotation()
        )

        # ── Episode tracking config ───────────────────────────────
        self._near_miss_threshold       = float(near_miss_threshold)
        self._collision_threshold       = float(collision_threshold)
        self._lap_departure_distance    = float(lap_departure_distance)
        self._lap_return_distance       = float(lap_return_distance)

        # ── Episode tracking state (populated by _reset_tracking) ─
        self._distance_travelled: float     = 0.0
        self._last_translation: List[float] = list(self._init_translation)
        self._has_departed: bool            = False
        self._lap_start_time: float         = 0.0
        self._laps_completed: int           = 0
        self._lap_times: List[float]        = []
        self._lap_just_completed_flag: bool = False
        self._near_miss_flag: bool          = False

        self.driver.step()          # must come first
        self.driver.setGear(1)      # now the transmission is ready
        self.driver.setCruisingSpeed(0.0)
        self.driver.setSteeringAngle(0.0)

    # ── Simulation control ────────────────────────────────────────

    def step(self) -> bool:
        """Advance one TIME_STEP. Returns False when Webots wants to quit.

        Also updates episode-level tracking (distance, lap detection,
        near-miss flag) after each successful step.
        """
        ok = self.driver.step() != -1
        if ok:
            self._update_tracking()
        return ok

    def reset(self):
        if self._first_reset:
            self._first_reset = False
            self._reset_tracking()
            return

        self.driver.setCruisingSpeed(0.0)
        self.driver.setSteeringAngle(0.0)

        trans_field = self.driver_node.getField("translation")
        rot_field   = self.driver_node.getField("rotation")
        trans_field.setSFVec3f(self._init_translation)
        rot_field.setSFRotation(self._init_rotation)
        self.driver_node.resetPhysics()

        for _ in range(5):
            self.driver.step()

        self._reset_tracking()

    # ── Episode tracking ──────────────────────────────────────────

    def _reset_tracking(self):
        """Clear all episode-level tracking state."""
        self._distance_travelled       = 0.0
        self._last_translation         = list(self._init_translation)
        self._has_departed             = False
        self._lap_start_time           = float(self.driver.getTime())
        self._laps_completed           = 0
        self._lap_times                = []
        self._lap_just_completed_flag  = False
        self._near_miss_flag           = False

    def _update_tracking(self):
        """Update distance, lap state and near-miss flag for the most recent step."""
        now     = float(self.driver.getTime())
        current = self.driver_node.getField("translation").getSFVec3f()

        # Path-length integration for total distance travelled.
        dx = current[0] - self._last_translation[0]
        dy = current[1] - self._last_translation[1]
        dz = current[2] - self._last_translation[2]
        self._distance_travelled += float(np.sqrt(dx * dx + dy * dy + dz * dz))
        self._last_translation = list(current)

        # Lap detection: arm after the car is far enough from spawn, then
        # fire exactly once when the car returns close to spawn.
        init = self._init_translation
        dxi  = current[0] - init[0]
        dyi  = current[1] - init[1]
        dzi  = current[2] - init[2]
        dist_from_init = float(np.sqrt(dxi * dxi + dyi * dyi + dzi * dzi))

        self._lap_just_completed_flag = False
        if not self._has_departed:
            if dist_from_init > self._lap_departure_distance:
                self._has_departed = True
        elif dist_from_init < self._lap_return_distance:
            self._lap_times.append(now - self._lap_start_time)
            self._lap_start_time = now
            self._laps_completed += 1
            self._has_departed = False
            self._lap_just_completed_flag = True

        # Near-miss: closest obstacle is inside the warning band but has
        # not crossed the collision threshold.
        d_min = self.get_min_lidar_distance()
        self._near_miss_flag = (
            self._collision_threshold < d_min <= self._near_miss_threshold
        )

    # ── Episode tracking accessors ────────────────────────────────

    def get_lap_completed(self) -> bool:
        """True iff a full lap was completed in the most recent step."""
        return self._lap_just_completed_flag

    def get_last_lap_time(self) -> Optional[float]:
        """Duration (s) of the most recently completed lap, or None if none yet."""
        return self._lap_times[-1] if self._lap_times else None

    def get_lap_times(self) -> List[float]:
        """All lap durations (s) completed since the last reset."""
        return list(self._lap_times)

    def get_laps_completed(self) -> int:
        return self._laps_completed

    def get_distance_travelled(self) -> float:
        """Cumulative path length (m) since the last reset."""
        return self._distance_travelled

    def is_near_miss(self) -> bool:
        """True iff the most recent step registered a near-miss."""
        return self._near_miss_flag

    # ── Sensor reads ──────────────────────────────────────────────

    def get_camera_image(self) -> np.ndarray:
        """(H, W, 3) uint8 RGB array."""
        raw = self.camera.getImage()
        img = np.frombuffer(raw, dtype=np.uint8).reshape((self.cam_h, self.cam_w, 4))
        return img[:, :, :3].copy()

    def get_lidar_scan(self) -> np.ndarray:
        scan = np.array(self.lidar.getRangeImage(), dtype=np.float32)
        scan = np.clip(np.nan_to_num(scan, nan=10.0, posinf=10.0), 0.0, 10.0)
        scan[scan < 0.32] = 10.0  # body noise peaks at 0.265, filter up to 0.32
        indices = np.linspace(0, len(scan) - 1, LIDAR_OUT_SIZE, dtype=int)
        return scan[indices]

    def is_collision(self) -> bool:
        """Returns list of contact points on this node."""
        contacts = self.driver_node.getContactPoints()
        return len(contacts) > 0

    def get_forward_speed(self) -> float:
        """
        Signed speed along the car's forward axis (m/s).
        Positive → moving forward, negative → moving backward.
        """
        v            = self.driver_node.getVelocity()[:3]
        rot          = np.array(self.driver_node.getOrientation()).reshape(3, 3)
        forward_axis = rot[:, 2]
        return float(np.dot(v, -forward_axis))

    def get_alignment_angle(self) -> float:
        """
        Normalised lateral offset of the yellow centre line ∈ [-1, 1].
        Negative → line is to the left of centre.
        Returns 1.0 when the line is not visible.

        NOTE: This is an image-plane proxy for cross-track error —
        a unitless fraction of half-image width, NOT metres.
        """
        img  = self.get_camera_image()
        hsv  = cv2.cvtColor(img, cv2.COLOR_RGB2HSV)
        mask = cv2.inRange(hsv, YELLOW_LO, YELLOW_HI)
        cols = np.where(mask.any(axis=0))[0]

        if len(cols) == 0:
            return 1.0

        cx     = float(cols.mean())
        centre = self.cam_w / 2.0
        return (cx - centre) / centre

    def get_min_lidar_distance(self) -> float:
        return float(self.get_lidar_scan().min())

    def set_controls(self, steering: float, throttle: float):
        angle = float(np.clip(steering, -1.0, 1.0)) * MAX_STEER
        speed = float(np.clip(throttle, -1.0, 1.0)) * MAX_SPEED
        self.driver.setSteeringAngle(angle)
        self.driver.setCruisingSpeed(speed)

    def apply_continuous(self, steering: float, throttle: float):
        """steering ∈ [-1, 1] (negative = left), throttle ∈ [-1, 1] (positive = forward)."""
        self.set_controls(steering, throttle)

    def apply_discrete(self, action: int):
        """0 = left | 1 = right | 2 = straight | 3 = brake."""
        cmds = {
            0: (-1.0,  0.5),
            1: ( 1.0,  0.5),
            2: ( 0.0,  1.0),
            3: ( 0.0,  0.0),
        }
        self.set_controls(*cmds[int(action)])
