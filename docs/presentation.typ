// ============================================================================
//  Autonomous Lane Following Vehicle — Presentation
//  Typst source. Compile with: typst compile presentation.typ
// ============================================================================

#let heading-font = "Liberation Sans"
#let body-font   = "Liberation Sans"

// ---- palette ---------------------------------------------------------------
#let red       = rgb("#C0203A")
#let red-deep  = rgb("#7C1426")
#let red-soft  = rgb("#F5E1E3")
#let cream     = rgb("#FBF3EE")
#let ink       = rgb("#2B2522")
#let muted     = rgb("#8A7D74")
#let hair      = rgb("#E7DAD3")
#let panel     = rgb("#FFFFFF")
#let stripe    = rgb("#F6ECE6")
#let green-ok  = rgb("#2A7A3B")
#let amber     = rgb("#B45309")

#set text(font: body-font, size: 16pt, fill: ink, lang: "en")
#set par(justify: false, leading: 0.62em, spacing: 0pt)
#set block(spacing: 0pt)

// ---- small helpers ----------------------------------------------------------
#let kicker(t) = text(font: heading-font, size: 12.5pt, weight: "bold", fill: red, tracking: 1.2pt)[#upper(t)]

#let h1(t) = text(font: heading-font, size: 28pt, weight: "bold", fill: ink)[#t]

#let rule() = line(length: 100%, stroke: 1.3pt + red)

// generic content slide --------------------------------------------------
#let slide(kicker-text: none, title: none, footer-note: "Autonomous Lane Following Vehicle", body) = page(
  paper: "presentation-16-9",
  margin: (top: 1.25cm, bottom: 1.25cm, left: 2cm, right: 2cm),
  fill: cream,
  footer: context [
    #set text(size: 9pt, fill: muted, font: body-font)
    #grid(
      columns: (1fr, 1fr),
      align: (left, right),
      [#footer-note],
      [#text(fill: red)[●] #counter(page).display("01")],
    )
  ],
)[
  #if kicker-text != none {
    kicker(kicker-text)
    v(2pt)
  }
  #if title != none {
    v(12pt)
    h1(title)
    v(16pt)
    rule()
    v(16pt)
  }
  #align(horizon)[#body]
]

// section divider (full red) ----------------------------------------------
#let divider(eyebrow: none, title, sub: none) = page(
  paper: "presentation-16-9",
  margin: 0pt,
  fill: red-deep,
)[
  #place(top + right, dx: 4cm, dy: -5cm, circle(radius: 7cm, fill: red, stroke: none))
  #place(bottom + left, dx: -3cm, dy: 3cm, circle(radius: 4.5cm, fill: none, stroke: 1.5pt + rgb("#ffffff33")))
  #place(bottom + left, dx: 2.4cm, dy: 1.6cm, circle(radius: 1.6cm, fill: none, stroke: 1.5pt + rgb("#ffffff22")))
  #place(center, dy: -0.6cm)[
    #if eyebrow != none [
      #text(font: heading-font, size: 14pt, weight: "bold", fill: rgb("#F3C9CF"), tracking: 2pt)[#upper(eyebrow)]
      #v(10pt)
    ]
    #v(200pt)
    #text(font: heading-font, size: 46pt, weight: "bold", fill: white)[#title]
    #if sub != none [
      #v(25pt)
      #text(font: body-font, size: 16pt, fill: rgb("#F3DCDF"))[#sub]
    ]
  ]
]

// ---- layout primitives -----------------------------------------------------
#let card(title: none, accent: red, w: 100%, body) = block(
  width: w,
  fill: panel,
  stroke: 1pt + hair,
  radius: 8pt,
  inset: 14pt,
  breakable: false,
)[
  #if title != none {
    block(width: 100%, above: 0pt, below: 8pt)[
      #rect(width: 3pt, height: 1em, fill: accent, radius: 1pt)
      #h(10pt)
      #text(font: heading-font, weight: "bold", size: 14pt, fill: ink, baseline: -0.9em)[#title]
    ]
  }
  #body
]

#let stat-card(num, label) = block(
  width: 100%,
  fill: panel,
  stroke: 1pt + hair,
  radius: 8pt,
  inset: (x: 12pt, y: 12pt),
)[
  #align(center)[
    #text(font: heading-font, size: 22pt, weight: "bold", fill: red)[#num]
    #v(8pt)
    #text(font: body-font, size: 11pt, fill: muted)[#label]
  ]
]

#let simple-table(cols, header, rows, align-first-left: true, font-size: 12pt) = {
  let cells = ()
  for h in header {
    cells.push(table.cell(fill: red)[#text(fill: white, weight: "bold", size: font-size, font: heading-font)[#h]])
  }
  for (i, r) in rows.enumerate() {
    let bgc = if calc.odd(i) { stripe } else { panel }
    for (j, c) in r.enumerate() {
      cells.push(table.cell(fill: bgc)[#text(size: font-size, fill: ink, weight: if j == 0 { "medium" } else { "regular" })[#c]])
    }
  }
  block(radius: 8pt, clip: true, stroke: 1pt + hair)[
    #table(
      columns: cols,
      stroke: 0.6pt + hair,
      inset: (x: 10pt, y: 7pt),
      align: (x, y) => if x == 0 and align-first-left { left } else { center },
      ..cells
    )
  ]
}

#let pill(t, fill-c: red-soft, text-c: red-deep) = box(
  fill: fill-c, radius: 4pt, inset: (x: 7pt, y: 3pt),
)[#text(font: body-font, size: 10.5pt, weight: "medium", fill: text-c)[#t]]

#let flow-box(title, sub: none, w: auto, fill-c: panel, accent: red) = box(
  width: w, fill: fill-c, stroke: 1pt + accent, radius: 6pt, inset: (x: 10pt, y: 8pt),
)[
  #align(center)[
    #text(font: heading-font, size: 9pt, weight: "bold", fill: ink)[#title]
    #if sub != none [
      #v(5pt)
      #text(font: body-font, size: 9.5pt, fill: muted)[#sub]
    ]
  ]
]

#let arrow-r = text(fill: muted, size: 16pt)[→]
#let arrow-d = text(fill: muted, size: 16pt)[↓]

// ============================================================================
//  TITLE SLIDE
// ============================================================================
#page(
  paper: "presentation-16-9",
  margin: 0pt,
  fill: cream,
)[
  // right band
  #place(top + right, dx: 0pt, dy: 0pt, rect(width: 10.4cm, height: 19.05cm, fill: red, stroke: none))
  #place(top + right, dx: 0pt, dy: 0pt, rect(width: 10.4cm, height: 6.4cm, fill: red-deep, stroke: none))
  #place(bottom + right, dx: 5cm, dy: 4cm, circle(radius: 4.5cm, fill: none, stroke: 1.5pt + rgb("#ffffff33")))
  #place(bottom + right, dx: 2cm, dy: 1cm, circle(radius: 1.6cm, fill: none, stroke: 1.5pt + rgb("#ffffff22")))
  #place(top + right, dx: -0.9cm, dy: 1.6cm)[
    #text(font: heading-font, size: 11.5pt, weight: "bold", fill: rgb("#F3DCDF"), tracking: 1.5pt)[#upper("Webots · RL")]
  ]
  // left content
  #place(left + horizon, dx: 2.1cm, dy: -0.4cm)[
    #block(width: 19.5cm)[
      #v(12pt)
      #text(font: heading-font, size: 41pt, weight: "bold", fill: ink)[Autonomous Lane Following Vehicle]
      #v(24pt)
      #line(length: 4.5cm, stroke: 1.4pt + red)
      #v(16pt)
      #grid(
        columns: (auto, auto, auto), column-gutter: 26pt,
        text(size: 12.5pt)[*Henrique Teixeira* \ #text(fill: muted, size: 10.5pt)[up202306640]],
        text(size: 12.5pt)[*João Pedro Ferreira* \ #text(fill: muted, size: 10.5pt)[up202306717]],
        text(size: 12.5pt)[*Miguel Almeida* \ #text(fill: muted, size: 10.5pt)[up202303926]],
      )
      #v(16pt)
      #pill("github.com/UShouldRun/Autonomous-Driving")
    ]
  ]
]

// ============================================================================
//  AGENDA
// ============================================================================
#slide(kicker-text: "Overview", title: "Agenda")[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 22pt,
    row-gutter: 14pt,
    card(title: "01 · Introduction")[#text(size: 12.5pt, fill: muted)[Motivation and project objective]],
    card(title: "02 · Approach")[#text(size: 12.5pt, fill: muted)[Observation space, LaneCNN architecture, DQN & PPO]],
    card(title: "03 · Reward & Evaluation")[#text(size: 12.5pt, fill: muted)[Reward shaping and the metrics used to score agents]],
    card(title: "04 · Training Environments")[#text(size: 12.5pt, fill: muted)[Custom Webots tracks built for training and testing]],
    card(title: "05 · Experiments & Results")[#text(size: 12.5pt, fill: muted)[Action space, cross-track general., obstacle avoidance]],
    card(title: "06 · Discussion & Conclusion")[#text(size: 12.5pt, fill: muted)[Key takeaways and future work]],
  )
]

// ============================================================================
//  01 — INTRODUCTION
// ============================================================================
#divider(eyebrow: "Section 01", "Introduction", sub: "Motivation and project objective")

#slide(kicker-text: "01 · Introduction", title: "Teaching a Car to See the Line")[
  #grid(
    columns: (1.1fr, 1fr),
    column-gutter: 28pt,
    [
      #text(size: 15pt)[
        We train an autonomous vehicle with Reinforcement Learning to stay
        centred on a yellow lane line and avoid static obstacles, end to
        end, directly from raw sensor input.
      ]
      #v(16pt)
      #text(size: 15pt)[
        The agent never receives a map or a rule set, only a camera
        frame, a LiDAR scan and its own speed at every step. Everything
        it does (steer, accelerate, swerve) is *learned* from a single
        shaped reward signal.
      ]
      #v(18pt)
      #grid(
        columns: (auto, auto), column-gutter: 10pt, row-gutter: 8pt,
        pill("Webots 2023b simulator", fill-c: red-soft, text-c: red-deep),
        pill("Gymnasium step / reset API", fill-c: red-soft, text-c: red-deep),
        pill("Camera + LiDAR + speed", fill-c: red-soft, text-c: red-deep),
        pill("DQN vs. PPO comparison", fill-c: red-soft, text-c: red-deep),
      )
    ],
    image(".city_level1.jpg", width: 100%),
  )
]

// ============================================================================
//  02 — APPROACH
// ============================================================================
#divider(eyebrow: "Section 02", "Approach", sub: "Observation space, LaneCNN architecture, DQN & PPO")

// --- Observation Space ---
#slide(kicker-text: "02 · Approach", title: "What the Agent Perceives")[
  #grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 18pt,
    card(title: "Camera")[
      #text(size: 12pt)[
        - $84 × 84 × 3$ RGB frame
        - $115°$ FOV
        - Tilted $tilde 6°$ downward
        - Bias toward the yellow line
      ]
    ],
    card(title: "LiDAR")[
      #text(size: 12pt)[
        - $8$ vertical layers 
        - $115°$ horizontal FOV
        - $23°$ vertical FOV clipped at $30 m$
        - Flattened into a norm. 1‑D vector
      ]
    ],
    card(title: "State")[
      #text(size: 12pt)[
        - Current forward velocity
        - Normalised to $[0,1]$
      ]
    ],
  )
  #v(18pt)
  #card(title: "Why fuse camera and LiDAR?")[
    #text(size: 12.5pt)[
      - Camera-only systems struggle give no direct distance signal
      - LiDAR-only systems lack context such as lane colour.
      - Fusing both streams: agent localises the line visually while reacting to obstacle proximity numerically.
    ]
  ]
]

// --- Network Architecture ---
#slide(kicker-text: "02 · Approach", title: "LaneCNN")[
  #grid(
    columns: (1.15fr, 1fr),
    column-gutter: 26pt,
    [
      #card(title: "Camera branch")[
        #text(size: 12pt)[
          - $5$ strided convulitional layers with batch-norm + ReLU
          - $"AdaptiveAvgPool2d"(4×4)$ 
        ]
        #v(20pt)
        #align(center)[
          #simple-table(
            (auto, auto, auto),
            ("Layer", "Channels", "Kernel / Stride"),
            (
              ("Conv 1", $3 → 32$,    $3 "/" 1$),
              ("Conv 2", $32 → 64$,   $3 "/" 2$),
              ("Conv 3", $64 → 128$,  $3 "/" 2$),
              ("Conv 4", $128 → 128$, $3 "/" 2$),
              ("Conv 5", $128 → 256$, $3 "/" 2$),
              ("Pool",   "—",         $"Adaptive" 4 × 4$),
            ),
          )
        ]
      ]
    ],
    [
      #card(title: "LiDAR branch")[
        #text(size: 12pt)[
          Two-layer MLP ($"LiDAR-dim" → 64 → 64$) with 
          ReLU encodes proximity into a *$64"-d"$* vector.
          ]
      ]
      #v(5pt)
      #card(title: "State branch")[
        #text(size: 12pt)[
          Single linear layer maps the velocity scalar 
          to a *$16"-d"$* embedding.
        ]
      ]
      #v(5pt)
      #card(title: "Joint head")[
        #text(size: 12pt)[
          The three embeddings are concatenated to 
          form a *$(512 + 64 + 16) = 592"-d"$* feature 
          vector fed to the policy and value heads.
        ]
      ]
    ],
  )
]

// --- Algorithms ---
#slide(kicker-text: "02 · Approach", title: "Algorithms — DQN vs. PPO")[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 22pt,
    card(title: "DQN — Discrete action space")[
      #text(size: 13pt)[
        Five named actions, each paired with a 
        fixed forward throttle
        to prevent stalling:
      ]
      #v(10pt)
      #grid(
        columns: (1fr, 1fr, 1fr),
        column-gutter: 6pt,
        row-gutter: 6pt,
        pill("Hard-Left"),
        pill("Hard-Right"),
        pill("Gentle-Left"),
        pill("Gentle-Right"),
        pill("Straight"),
      )
      #v(12pt)
      #text(size: 12.5pt)[
        Implemented with *experience replay* 
        ($|cal(D)| = 10^4$) and
        $epsilon$-greedy exploration.
        \
        Fixed 
        actions simplify early
        exploration but limit fine steering resolution.
      ]
    ],
    card(title: "PPO — Continuous action space")[
      #text(size: 13pt)[
        Outputs steering $phi in [-1, 1]$ and 
        throttle $a in [0,1]$
        as a diagonal Gaussian distribution.
      ]
      #v(20pt)
      #align(center)[
        #simple-table(
          (auto, auto),
          ("Hyperparameter", "Value"),
          (
            ("Clip " + $epsilon$,     $0.2$),
            ("GAE-" + $lambda$,       $0.95$),
            ("Entropy coefficient",   $0.01$),
            ("Learning rate",         $10^(-4)$),
            ("Batch size",            $128$),
          ),
        )
      ]
    ],
  )
]

// ============================================================================
//  03 — REWARD & EVALUATION
// ============================================================================
#divider(eyebrow: "Section 03", "Reward & Evaluation", sub: "Reward shaping and the metrics used to score agents")

// --- Reward Function ---
#slide(kicker-text: "03 · Reward & Evaluation", title: "Dense Reward Function")[
  #grid(
    columns: (2.8fr, 1fr),
    column-gutter: 26pt,
    [
      #card(title: "Reward decomposition")[
        #text(size: 16pt)[
          $ R = r_"exist" + r_"progress" + r_"speed" + r_"lap" - r_"align" - r_"near" $
        ]
        #v(10pt)
        #simple-table(
          (auto, auto),
          ("Term", "Formula"),
          (
            ([*Existence*],        [$r_"exist" = w_e$]),
            ([*Progress*],         [$r_"progress" = w_p dot Delta d dot (1 + w_b (1 - |theta|))$]),
            ([*Speed*],            [$r_"speed" = w_s dot hat(v) dot (1 + w_b (1-|theta|) + w_i dot Delta|theta|^+)$]),
            ([*Alignment penalty*],[$r_"align" = w_a |theta|$]),
            ([*Near-miss*],        [$r_"near" = w_n dot bb(1)["near miss"]$]),
            ([*Lap bonus*],        [$r_"lap" = w_"lap"$]),
          ),
          font-size: 16pt,
        )
      ]
    ],
    [
      #simple-table(
        (auto, auto),
        ("Weight", "Value"),
        (
          ([$w_e$ (existence)],   "0.01"),
          ([$w_p$ (progress)],    "4.0"),
          ([$w_s$ (speed)],       "4.0"),
          ([$w_b$ (alignment)],   "4.0"),
          ([$w_i$ (improve)],     "10.0"),
          ([$w_a$ (penalty)],     "10.0"),
          ([$w_n$ (near miss)],   "5.0"),
          ([$w_"lap"$ (lap)],     "50.0"),
          ([$w_t$ (terminated)],  "100.0"),
        ),
        font-size: 15pt,
      )
    ],
  )
]

// --- Evaluation Metrics ---
#slide(kicker-text: "03 · Reward & Evaluation", title: "Evaluation Metrics")[
  #v(8pt)
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 22pt,
    row-gutter: 16pt,
    card(title: "Success Rate (%)")[
      #text(size: 13pt)[
        Percentage of evaluation episodes completed without any
        collision or line-loss termination event. \
        *Higher is better.*
      ]
    ],
    card(title: "Cross-Track Error — CTE (m)")[
      #text(size: 13pt)[
        Average lateral distance between the vehicle centre and the
        yellow centre line, measured every step. \
        *Lower is better.*
      ]
    ],
    card(title: "Mean Lap Time (s)")[
      #text(size: 13pt)[
        Wall-clock time to complete one full circuit of the track.
        Rewards faster, smoother driving. \
        *Lower is better.*
      ]
    ],
    card(title: "Near Miss count")[
      #text(size: 13pt)[
        Mean count of instances where
        the vehicle gets dangerously close
        to an obstacle recorded by LiDAR. \
        *Lower is better.*
      ]
    ],
  )
  #v(14pt)
  #text(size: 12pt, fill: muted)[Each model is evaluated over *10 episodes per track*. All metrics are averaged across those episodes.]
]

// ============================================================================
//  04 — TRAINING ENVIRONMENTS
// ============================================================================
#divider(eyebrow: "Section 04", "Training Environments", sub: "Custom Webots tracks built for training and testing")

#slide(kicker-text: "04 · Training Environments", title: "Three Custom Looped Tracks")[
  #grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 18pt,
    [
      #card(title: "Track 1: Training")[
        #text(size: 11.5pt)[Simple rounded loop. Used for initial DQN and PPO training via #text(weight:"bold")[config.yaml]. Gentle curves only.]
        #v(8pt)
        #box(radius: 8pt, clip: true, image(".city_level1.jpg", width: 100%, height: 5cm, fit: "cover"))
      ]
    ],
    [
      #card(title: "Track 2: Fine-tuning")[
        #text(size: 11.5pt)[Tighter curves and varying road width. Both agents fine-tuned here via #text(weight:"bold")[finetune.yaml].]
        #v(8pt)
        #box(radius: 8pt, clip: true, image(".city_level2.jpg", width: 132%, height: 5cm, fit: "cover"))
      ]
    ],
    [
      #card(title: "Track 3: Zero-shot eval")[
        #text(size: 11.5pt)[More complex layout: similar, but different curves. Used *exclusively* for zero-shot generalisation evaluation.]
        #v(8pt)
        #box(radius: 8pt, clip: true, image(".city_level3.jpg", width: 100%, height: 5cm, fit: "cover"))
      ]
    ],
  )
]

// ============================================================================
//  05 — EXPERIMENTS & RESULTS
// ============================================================================
#divider(eyebrow: "Section 05", "Experiments & Results", sub: "Action space · Cross-track generalisation · Obstacle avoidance")

// --- Experiment 1 setup ---
#slide(kicker-text: "05 · Experiments", title: "Experiment 1: Action Space")[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 22pt,
    [
      #card(title: "Goal")[
        #text(size: 13.5pt)[
          Compare DQN (discrete) and PPO (continuous) trained
          under the *same dense reward* on Track 1. Evaluate
          which action-space design produces better lane-keeping
          and lap efficiency.
        ]
      ]
      #v(12pt)
      #card(title: "Hypothesis")[
        #text(size: 13.5pt)[
          PPO will achieve smoother control due to continuous
          steering and throttle authority.
          \
          DQN's fixed action set may produce jagged corrections
          that keep the vehicle close to the line but slow it down.
        ]
      ]
    ],
    card(title: "Training setup")[
      #text(size: 13pt)[*Environment:*]
      #v(8pt)
      #text(size: 12pt)[Webots Track 1: simple rounded loop]
      #v(12pt)
      #text(size: 13pt)[*Config:*]
      #v(8pt)
      #text(size: 12pt)[`config.yaml`: shared hyperparameters]
      #v(12pt)
      #text(size: 13pt)[*Evaluation:*]
      #v(8pt)
      #text(size: 12pt)[10 episodes each \ Success · CTE · Lap time]
    ],
  )
]

// --- Experiment 1 results ---
#slide(kicker-text: "05 · Results", title: "Experiment 1: Track 1 results")[
  #grid(
    columns: (auto, 1fr),
    column-gutter: 28pt,
    align: (horizon, auto),
    [
      #simple-table(
        (auto, auto, auto),
        ("Metric", "PPO T1", "DQN T1"),
        (
          ("Success " + $(%)$,   $100$,   $100$),
          ("CTE " + $(m)$,       $0.173$, $0.056$),
          ("Lap " + $(s)$,       $43.1$,  $49.2$),
          ("Dist " + $(m)$,      $1209$,  $1074$),
          ("Near Miss",          $0.0$,   $0.0$),
        ),
      ) 
    ],
    [
      #box(radius: 8pt, clip: true, image("track1_comparison.png", width: 100%, fit: "cover"))
    ],
  )
]

// --- Experiment 2 setup ---
#slide(kicker-text: "05 · Experiments", title: "Experiment 2: Cross-Track Generalisation")[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 22pt,
    [
      #card(title: "Goal")[
        #text(size: 13.5pt)[
          Evaluate whether policies trained on Track 1 and
          fine-tuned on Track 2 can *transfer zero-shot* to the
          unseen Track 3 without any additional training.
        ]
      ]
      #v(12pt)
      #card(title: "Hypothesis")[
        #text(size: 13.5pt)[
          The alignment-gated reward and multi-sensor features
          encourage learning structural driving behaviours rather
          than memorising track-specific layouts.
        ]
      ]
    ],
    card(title: "Training setup")[
      #grid(
        columns: (auto, auto, auto, auto, auto),
        column-gutter: 8pt,
        align: center + horizon,
        flow-box("Train on T1", sub: "config.yaml"),
        arrow-r,
        flow-box("Fine-tune on T2", sub: "finetune.yaml"),
        arrow-r,
        flow-box("Zero-shot eval T3", sub: "No retraining", fill-c: red-soft, accent: red),
      )    
    ],
  )
]

// --- Experiment 2 results ---
#slide(kicker-text: "05 · Results", title: "Experiment 2: Cross-track generalisation")[
  #grid(
    columns: (auto, 1fr),
    column-gutter: 28pt,
    [
      #simple-table(
        (auto, auto, auto, auto, auto),
        ("Metric", "PPO T2", "DQN T2", "PPO T3", "DQN T3"),
        (
          ("Success " + $(%)$,  $100$,   $100$,   $60$,    $0$),
          ("CTE " + $(m)$,      $0.104$, $0.060$, $0.111$, $0.082$),
          ("Lap " + $(s)$,      $60.8$,  $74.6$,  $65.1$,  $N/A$),
          ("Dist " + $(m)$,     $1326$,  $1086$,  $1021$,  $742$),
          ("Near Miss",         $0.0$,   $0.0$,   $0.2$,   $0.0$),
        ),
      )
    ],
    [
      #card(title: "PPO on Track 3 — 60% success")[
        #text(size: 12pt)[$6 "/" 10$ episodes completed. The $4$ failures share a common cause: a sharp isolated curve pushes the yellow line out of the camera's lower region-of-interest momentarily, triggering line-lost termination.]
      ]
      #v(10pt)
      #card(title: "DQN on Track 3 — 0% success")[
        #text(size: 12pt)[All $10$ episodes fail at the *same location*: two consecutive turns sharper than anything seen in training. DQN's rigid discrete mapping lacks the fine steering resolution needed to clear tight radii, causing it to run off-track at $~75%$ completion.]
      ]
    ],
  )
]

// --- Experiment 2 chart ---
#slide(kicker-text: "05 · Results", title: "Track 3: Per-Episode Reward & Failure Clusters")[
  #grid(
    columns: (1.8fr, 1fr),
    column-gutter: 28pt,
    align: horizon,
    box(radius: 8pt, clip: true)[
      #image("track3_rewards.png", width: 100%)
    ],
    [
      #card(title: "Reading the chart")[
        #text(size: 12pt)[
          *Green triangles* mark PPO successes ($"reward" ≈ 180" "000$).
          \
          *Red triangles* mark PPO failures — $"reward"$ drops to $≈ 85" "000$, always at the same sharp-bend cluster.
          \
          *DQN (blue)* hovers around $100" "000$ — consistent partial completion, but never clears the obstacle section.
        ]
      ]
      #v(10pt)
      #card(accent: amber)[
        #text(size: 11.5pt)[PPO's continuous steering gives it *60% generalisation* on unseen geometry; DQN's discrete action mapping is a hard constraint it cannot overcome zero-shot.]
      ]
    ],
  )
]

// --- Experiment 3 setup ---
#slide(kicker-text: "05 · Experiments", title: "Experiment 3: Obstacle Avoidance")[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 22pt,
    [
      #card(title: "Goal")[
        #text(size: 13.5pt)[
          Evaluate the ability of pre-trained agents to *integrate
          LiDAR distance data* and steer around static barrel
          obstacles when fine-tuned using `obstacles.yaml` on
          Track 1 with barrels placed on the road.
        ]
      ]
      #v(12pt)
      #card(title: "Hypothesis")[
        #text(size: 13.5pt)[
          The 1-D LiDAR vector paired with the proximity penalty
          $r_"near"$ will let agents navigate around static barrels
          *without losing* baseline lane-keeping competency.
        ]
      ]
    ],
    card(title: "Training setup")[
      #grid(
        columns: (1fr, 1fr, 1fr),
        column-gutter: 14pt,
        align: center,
        [#text(size: 12pt)[*Init:* \ Best baseline checkpoints \ (post T1 + T2)]],
        [#text(size: 12pt)[*Fine-tune:* \ `obstacles.yaml` \ Static barrels \ on T1]],
        [#text(size: 12pt)[*Key metric:* \ Near Miss count \ + \ Success rate]],
      )    
    ],
  )
]

// --- Experiment 3 results ---
#slide(kicker-text: "05 · Results", title: "Experiment 3: Obstacle avoidance results")[
  #grid(
    columns: (auto, 1fr),
    column-gutter: 28pt,
    [
      #simple-table(
        (auto, auto, auto),
        ("Metric", "PPO Obs.", "DQN Obs."),
        (
          ("Success (%)",  "0",     "0"),
          ("CTE (m)",      "0.153", "0.057"),
          ("Lap (s)",      "N/A",   "N/A"),
          ("Dist (m)",     "580",   "120"),
          ("Near Miss",    "2.4",   "1.0"),
        ),
      )
    ],
    [
      #card(title: "PPO: Partial avoidance capability")[
        #text(size: 12pt)[
          *Learned local swerving maneuvers*. \
          When encountering a barrel, 
          *executes a smooth bypass*. \
          *Path corrections* push the vehicle 
          into *unrecoverable* states. \
          Consistently completes *$tilde 50%$ 
          or $580 m$* of the track.
        ]
      ]
      #v(10pt)
      #card(title: "DQN: Total failure")[
        #text(size: 12pt)[
          Unable to avoid *even a single obstacle*. \
          Discrete actions cannot blend 
          visual tracking with rapid proximity corrections. \
          The *dense reward suppresses 
          LiDAR features* entirely to maintain 
          lane position. \
          The agent *drives straight into barrels*.
        ]
      ]
    ],
  )
]

// ============================================================================
//  06 — DISCUSSION & CONCLUSION
// ============================================================================
#divider(eyebrow: "Section 06", "Discussion & Conclusion", sub: "Key takeaways and future work")

#slide(kicker-text: "06 · Discussion", title: "Action Space Elasticity: The Key Distinction")[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 22pt,
    card(title: "PPO: Continuous control", accent: green-ok)[
      #text(size: 12.5pt)[
        - *Continuous action* allows discovery of the *balance* between *lane tracking with LiDAR features*.
        \
        - *Minute steering* adjustments *preserve line visibility* while initiating a swerve.
        \
        - *Partial success*: $60%$ on unseen geometry, $50%$ with obstacles.
      ]
    ],
    card(title: "DQN: Discrete mapping", accent: red)[
      #text(size: 12.5pt)[
        - Discrete action requires *large, sudden* steering changes.
        \
        - The primary gradient path *suppresses LiDAR features* entirely to maintain tracking stability.
        \
        - *Zero success* on sharp unseen curves and total failure on obstacle avoidance.
      ]
    ],
  )
]

#slide(kicker-text: "06 · Conclusion", title: "Key takeaways & future work")[
  #grid(
    columns: (1fr, 1fr),
    column-gutter: 22pt,
    [
      #card(title: "Summary of findings")[
        #text(size: 12.5pt)[
          - Both agents achieve *100% success* on simple and medium tracks.
          #v(24pt)
          - PPO generalises to unseen geometry at *60%*.
          - DQN fails at *0%* due to rigid discrete actions.
          #v(24pt)
          - Obstacle avoidance: 
            - PPO learns local swerves (*50% track*);
            - DQN ignores obstacles entirely;
          #v(24pt)
          - Action-space granularity is a *critical architectural parameter* for multi-modal driving agents.
        ]
      ]
    ],
    [
      #card(title: "Future work")[
        #text(size: 12.5pt)[
          *1. Network architecture* \
          Explicit attention mechanisms or decoupled value streams to force equal weighting across sensor modalities, preventing feature domination.

          #v(15pt)
          *2. Reward engineering* \
          Curriculum learning — master obstacle avoidance with LiDAR in isolation *before* reintroducing visual lane tracking data.

          #v(15pt)
          *3. Extended action spaces* \
          Hierarchical or hybrid discrete-continuous action spaces for DQN.
        ]
      ]
    ],
  )
  #v(14pt)
  #grid(
    columns: (1fr, 1fr, 1fr, 1fr),
    column-gutter: 12pt,
    stat-card($100%$)[Track 1 & 2 success],
    stat-card($60%$)[PPO zero-shot T3],
    stat-card($0%$)[DQN zero-shot T3],
    stat-card($~50%$)[PPO obstacle track],
  )
]

// ============================================================================
//  DEMO SLIDE
// ============================================================================
#divider(eyebrow: "Section 07", "Demonstration", sub: "https://drive.google.com/drive/folders/1YPLRe94yxvUS1eZuZ-2r8PzcXoAIwRo7?usp=sharing")

// ============================================================================
//  END SLIDE — repeat title slide
// ============================================================================
#page(
  paper: "presentation-16-9",
  margin: 0pt,
  fill: cream,
)[
  // right band
  #place(top + right, dx: 0pt, dy: 0pt, rect(width: 10.4cm, height: 19.05cm, fill: red, stroke: none))
  #place(top + right, dx: 0pt, dy: 0pt, rect(width: 10.4cm, height: 6.4cm, fill: red-deep, stroke: none))
  #place(bottom + right, dx: 5cm, dy: 4cm, circle(radius: 4.5cm, fill: none, stroke: 1.5pt + rgb("#ffffff33")))
  #place(bottom + right, dx: 2cm, dy: 1cm, circle(radius: 1.6cm, fill: none, stroke: 1.5pt + rgb("#ffffff22")))
  #place(top + right, dx: -0.9cm, dy: 1.6cm)[
    #text(font: heading-font, size: 11.5pt, weight: "bold", fill: rgb("#F3DCDF"), tracking: 1.5pt)[#upper("Webots · RL")]
  ]
  // left content
  #place(left + horizon, dx: 2.1cm, dy: -0.4cm)[
    #block(width: 19.5cm)[
      #v(12pt)
      #text(font: heading-font, size: 41pt, weight: "bold", fill: ink)[Autonomous Lane Following Vehicle]
      #v(24pt)
      #line(length: 4.5cm, stroke: 1.4pt + red)
      #v(16pt)
      #grid(
        columns: (auto, auto, auto), column-gutter: 26pt,
        text(size: 12.5pt)[*Henrique Teixeira* \ #text(fill: muted, size: 10.5pt)[up202306640]],
        text(size: 12.5pt)[*João Pedro Ferreira* \ #text(fill: muted, size: 10.5pt)[up202306717]],
        text(size: 12.5pt)[*Miguel Almeida* \ #text(fill: muted, size: 10.5pt)[up202303926]],
      )
      #v(16pt)
      #pill("github.com/UShouldRun/Autonomous-Driving")
    ]
  ]
]

