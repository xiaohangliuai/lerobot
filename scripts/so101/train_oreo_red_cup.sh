#!/usr/bin/env bash
set -euo pipefail

# Train ACT on the reviewed Oreo demonstrations. The robot is not used in training.
# From the repository root: ./scripts/so101/train_oreo_red_cup.sh
# Override defaults with additional lerobot-train flags, e.g. --steps=40000.
# Initial baseline: 20,000 updates at batch size 8 (~8.7 passes over 18,474 frames).

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
cd -- "$REPO_ROOT"

if command -v uv >/dev/null 2>&1; then
    trainer=(uv run --no-sync lerobot-train)
elif command -v lerobot-train >/dev/null 2>&1; then
    trainer=(lerobot-train)
else
    echo "Activate your LeRobot environment first: conda activate lerobot" >&2
    exit 1
fi

# Keep the full console history for learning curves and troubleshooting.
# Logs live outside output_dir because the trainer requires a fresh output folder.
LOG_DIR="$REPO_ROOT/outputs/logs"
mkdir -p -- "$LOG_DIR"
LOG_FILE="$LOG_DIR/train_oreo_red_cup_$(date +%Y%m%d_%H%M%S).log"
echo "Saving training log to $LOG_FILE"

"${trainer[@]}" \
    --dataset.repo_id=local/oreo_red_cup \
    --dataset.root="$REPO_ROOT/outputs/datasets/oreo_red_cup" \
    --policy.type=act \
    --policy.device=cuda \
    --policy.push_to_hub=false \
    --output_dir="$REPO_ROOT/outputs/train/act_oreo_red_cup" \
    --job_name=act_oreo_red_cup \
    --batch_size=8 \
    --steps=20000 \
    --save_freq=5000 \
    --log_freq=100 \
    --env_eval_freq=0 \
    --wandb.enable=false \
    "$@" 2>&1 | tee -a "$LOG_FILE"
