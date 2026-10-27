#!/usr/bin/env bash
set -euo pipefail

# Record 50 demonstrations with the same arms/cameras as teleoperate_so101.sh.
# Stop teleoperation first, power both arms, and place the Oreo packet and red
# cup within reach and in view. Reuse the existing arm calibrations.
# From the repository root:
# Usage: ./scripts/so101/record_oreo_red_cup.sh [additional lerobot-record options]
# Example: ./scripts/so101/record_oreo_red_cup.sh --dataset.episode_time_s=45
# First batch of 10: ./scripts/so101/record_oreo_red_cup.sh --dataset.num_episodes=10
# Next batch of 10: ./scripts/so101/record_oreo_red_cup.sh --resume=true --dataset.num_episodes=10
# On resume, num_episodes is the number of ADDITIONAL episodes to record.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
cd -- "$REPO_ROOT"

# Prefer uv; also support the activated environment used by the existing scripts.
if command -v uv >/dev/null 2>&1; then
    recorder=(uv run --no-sync lerobot-record)
elif command -v lerobot-record >/dev/null 2>&1; then
    recorder=(lerobot-record)
else
    echo "Activate your LeRobot environment first (the one used for teleoperation)." >&2
    exit 1
fi

cat <<'EOF'
Task: Pick up the Oreo packet and put it into the red cup.
Defaults: 50 episodes, up to 30 seconds each, 15 seconds to reset, 30 FPS.
Local dataset: outputs/datasets/oreo_red_cup (no upload).
Recording starts after the arms and cameras connect; have the scene ready.
Keep this terminal focused for keyboard controls:
  Right / n : end the episode early, or finish the reset early
  Left  / r : discard the current attempt and re-record it
  Esc   / q : finish early (saves the current attempt)
During each reset, return the arm and packet to their starting positions.
EOF

exec "${recorder[@]}" \
    --robot.type=so101_follower \
    --robot.port=/dev/serial/by-id/usb-1a86_USB_Single_Serial_5B90103298-if00 \
    --robot.id=so101_follower_white \
    --robot.cameras="{top: {type: opencv, index_or_path: /dev/v4l/by-id/usb-Web_Camera_Web_Camera_202512181-video-index0, width: 640, height: 480, fps: 30, rotation: 0, fourcc: MJPG}, wrist: {type: opencv, index_or_path: /dev/v4l/by-id/usb-Generic_USB_HD_Camera_200910120001-video-index0, width: 640, height: 480, fps: 30, rotation: 0, fourcc: MJPG}}" \
    --teleop.type=so101_leader \
    --teleop.port=/dev/serial/by-id/usb-1a86_USB_Single_Serial_5B90100708-if00 \
    --teleop.id=so101_leader_black \
    --dataset.repo_id=local/oreo_red_cup \
    --dataset.root="$REPO_ROOT/outputs/datasets/oreo_red_cup" \
    --dataset.no_stamp=true \
    --dataset.single_task="Pick up the Oreo packet and put it into the red cup." \
    --dataset.num_episodes=50 \
    --dataset.episode_time_s=30 \
    --dataset.reset_time_s=15 \
    --dataset.fps=30 \
    --dataset.push_to_hub=false \
    --display_data=false \
    "$@"
