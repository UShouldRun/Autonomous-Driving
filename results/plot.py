import os
import matplotlib.pyplot as plt
import pandas as pd

def generate_evaluation_plots():
    if 'seaborn-v0_8-whitegrid' in plt.style.available:
        plt.style.use('seaborn-v0_8-whitegrid')
    else:
        plt.style.use('default')
        
    plt.rcParams.update({
        'font.size': 10,
        'axes.labelsize': 11,
        'axes.titlesize': 12,
        'xtick.labelsize': 9,
        'ytick.labelsize': 9,
        'figure.titlesize': 13,
        'legend.fontsize': 9
    })

    files_to_load = {
        'dqn_t1': "eval_best_dqn_10ep_level_1.csv",
        'ppo_t1': "eval_best_ppo_10ep_level_1.csv",
        'dqn_t3': "eval_best_dqn_10ep_level_3.csv",
        'ppo_t3': "eval_best_ppo_10ep_level_3.csv",
    }
    
    data = {}
    for key, filename in files_to_load.items():
        if not os.path.exists(filename):
            raise FileNotFoundError(
                f"Missing required file: '{filename}'. Please ensure it is in the working directory."
            )
        data[key] = pd.read_csv(filename)

    print("Data loaded successfully. Processing zero-anchored plots...")

    fig1, axes = plt.subplots(1, 2, figsize=(10, 4.5))

    # Left Panel: Total Reward
    axes[0].plot(data['dqn_t1']['episode'], data['dqn_t1']['total_reward'], 
                 marker='o', color='#1f77b4', label='DQN', linewidth=2)
    axes[0].plot(data['ppo_t1']['episode'], data['ppo_t1']['total_reward'], 
                 marker='s', color='#ff7f0e', label='PPO', linewidth=2)
    axes[0].set_title("Evaluation Reward on Track 1")
    axes[0].set_xlabel("Episode")
    axes[0].set_ylabel("Total Reward")
    axes[0].set_xticks(range(1, 11))
    axes[0].legend(loc='lower right')
    
    # Anchor Left Panel to Zero
    axes[0].set_xlim(left=0)
    axes[0].set_ylim(bottom=0, top=200000)
    axes[0].margins(x=0)

    # Right Panel: Cross-Track Error (CTE)
    axes[1].plot(data['dqn_t1']['episode'], data['dqn_t1']['mean_cte'], 
                 marker='o', color='#1f77b4', label='DQN', linewidth=2)
    axes[1].plot(data['ppo_t1']['episode'], data['ppo_t1']['mean_cte'], 
                 marker='s', color='#ff7f0e', label='PPO', linewidth=2)
    axes[1].set_title("Cross-Track Error (CTE) on Track 1")
    axes[1].set_xlabel("Episode")
    axes[1].set_ylabel("Mean CTE (m)")
    axes[1].set_xticks(range(1, 11))
    axes[1].legend(loc='lower right')
    
    # Anchor Right Panel to Zero
    axes[1].set_xlim(left=0)
    axes[1].set_ylim(bottom=0,top=0.2)
    axes[1].margins(x=0)

    plt.tight_layout()
    fig1.savefig("track1_comparison.png", dpi=300)
    plt.close(fig1)
    print("-> Saved: track1_comparison.png")

    fig2, ax = plt.subplots(figsize=(6.5, 4.5))

    # Filter PPO into success vs failure categories
    success_mask = data['ppo_t3']['termination_reason'] == 'eval_max_steps'
    ppo_success = data['ppo_t3'][success_mask]
    ppo_fail = data['ppo_t3'][~success_mask]

    # Continuous lines for DQN and PPO
    ax.plot(data['dqn_t3']['episode'], data['dqn_t3']['total_reward'],
            color='#1f77b4', linewidth=2, label='DQN (All Fail)')
    ax.plot(data['ppo_t3']['episode'], data['ppo_t3']['total_reward'],
            color='#ff7f0e', linewidth=2, label='PPO')

    # Overlay scatter markers to highlight success vs failure on PPO line
    ax.scatter(ppo_success['episode'], ppo_success['total_reward'],
               color='#2ca02c', marker='^', s=100, zorder=5, label='PPO (Success)')
    ax.scatter(ppo_fail['episode'], ppo_fail['total_reward'],
               color='#d62728', marker='v', s=100, zorder=5, label='PPO (Fail)')
    ax.scatter(data['dqn_t3']['episode'], data['dqn_t3']['total_reward'],
               color='#1f77b4', marker='o', s=100, zorder=5)

    # Drawing horizontal dashed cluster flags
    ax.axhline(y=112000, color='#1f77b4', linestyle='--', alpha=0.4)
    ax.axhline(y=99000, color='#1f77b4', linestyle='--', alpha=0.4)
    ax.axhline(y=83000, color='#d62728', linestyle='--', alpha=0.4)

    ax.set_title("Per-Episode Reward & Failure Clusters on Track 3")
    ax.set_xlabel("Episode")
    ax.set_ylabel("Total Reward")
    ax.set_xticks(range(1, 11))

    ax.set_xlim(left=0)
    ax.set_ylim(bottom=0, top=210000)
    ax.margins(x=0)
    ax.legend(loc='lower right', frameon=True)

    plt.tight_layout()
    fig2.savefig("track3_rewards.png", dpi=300)
    plt.close(fig2)
    print("-> Saved: track3_rewards.png")

if __name__ == "__main__":
    generate_evaluation_plots()
