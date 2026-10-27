#!/usr/bin/env bash
set -euo pipefail

# Black leader. Stop teleoperation before running calibration.
# At the existing-calibration prompt, enter c to perform a new calibration.
exec lerobot-calibrate \
    --teleop.type=so101_leader \
    --teleop.port=/dev/serial/by-id/usb-1a86_USB_Single_Serial_5B90100708-if00 \
    --teleop.id=so101_leader_black \
    "$@"
