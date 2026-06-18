# DQN vs. PPO: Action Space Constraints in Autonomous Driving

**Group A** — João Ferreira (up202306717) · Henrique Teixeira (up202306640) · Miguel Almeida (up202303926)

## Overview

Train autonomous vehicle agents using Deep Reinforcement Learning (DQN and PPO)
to follow a yellow centre line and avoid static obstacles in Webots.
Agents process fused Camera + LiDAR data through a custom multi-branch CNN (LaneCNN)
and output steering/throttle commands. While both agents achieve 100% success on 
trained tracks, evaluation on an unseen complex track reveals severe generalisation 
limits — PPO achieves 60% success via continuous steering authority; 
DQN fails entirely at sharp unseen curves.

## NOTE

For testing PPO with obstacles, 
clone the repo from GitHub 
[github.com/UShouldRun/Autonomous-Driving](https://github.com/UShouldRun/Autonomous-Driving)
with:

```bash
git clone git@github.com:UShouldRun/Autonomous-Driving
```

The model is in the file `results/best_ppo_obstacles.zip`.

## Setup

```bash
pip install -r requirements.txt

export WEBOTS_HOME=/usr/local/webots  # Webots 2023b+ required
```

## Usage

```bash
# Train on Track 1
python exps/train.py --agent ppo --reward dense

# Fine-tune on Track 2
python exps/train.py --agent ppo --config finetune.yaml

# Fine-tune for obstacle avoidance
python exps/train.py --agent ppo --config obstacles.yaml

# Evaluate a saved model
python exps/eval.py --checkpoint results/ppo_dense_best.zip
```

## Experiments

| # | Name | Goal |
|---|------|------|
| 1 | Action Space | DQN (discrete, 5 actions) vs PPO (continuous steering + throttle) under same dense reward on Track 1 |
| 2 | Cross-Track Generalisation | Zero-shot transfer of Track 1+2-trained policies to unseen Track 3 |
| 3 | Obstacle Avoidance | Fine-tune pre-trained agents to avoid static barrels on Track 1 |

Each experiment evaluated over **10 episodes per track**.

## Results Summary

| Metric | PPO T1 | PPO T2 | PPO T3 | DQN T1 | DQN T2 | DQN T3 | PPO Obs. | DQN Obs. |
|--------|--------|--------|--------|--------|--------|--------|----------|----------|
| Success (%) | 100 | 100 | 60 | 100 | 100 | 0 | 0 | 0 |
| CTE (m) | 0.173 | 0.104 | 0.111 | 0.056 | 0.060 | 0.082 | 0.153 | 0.057 |
| Lap (s) | 43.1 | 60.8 | 65.1 | 49.2 | 74.6 | N/A | N/A | N/A |
| Dist (m) | 1209 | 1326 | 1021 | 1074 | 1086 | 742 | 580 | 120 |
| Near Miss | 0.0 | 0.0 | 0.2 | 0.0 | 0.0 | 0.0 | 2.4 | 1.0 |

## Key Findings

- **Action space matters for generalisation**: PPO's continuous steering resolves sharp unseen curves (60% on Track 3); DQN's 5-action discrete mapping fails entirely (0%) at two consecutive turns sharper than any in training.
- **Obstacle avoidance exposes task-composition limits**: PPO learns local swerving maneuvers but degrades lane-following over distance, capping at ~50% track completion. DQN suppresses LiDAR features entirely under the dense reward, failing to avoid a single obstacle.
- **Reward exploitation**: DQN achieves tighter tracking (CTE 0.056 m vs 0.173 m) but slower laps; PPO cuts corners to maximise the speed reward term.

## Evaluation Metrics

| Metric | Description |
|--------|-------------|
| Success Rate (%) | Trials completed without collision |
| Cross-Track Error (m) | Average lateral distance from yellow centre line |
| Mean Lap Time (s) | Time to complete one full circuit |
| Near Miss | Mean LiDAR-recorded instances of dangerous proximity to obstacle |

## Network Architecture (LaneCNN)

Three-branch feature extractor fusing camera, LiDAR and velocity state:

- **Camera branch**: 5 strided conv layers (3→32→64→128→128→256) + AdaptiveAvgPool(4×4) → 512-d vector
- **LiDAR branch**: 2-layer MLP (LiDAR-dim→64→64) → 64-d vector  
- **State branch**: linear → 16-d embedding  
- **Joint**: 592-d concatenation fed to policy/value heads
