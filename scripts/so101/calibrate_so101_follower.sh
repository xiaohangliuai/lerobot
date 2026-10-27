#!/usr/bin/env bash
set -euo pipefail

# White follower. Stop teleoperation before running calibration.
# At the existing-calibration prompt, enter c to perform a new calibration.
exec lerobot-calibrate \
    --robot.type=so101_follower \
    --robot.port=/dev/serial/by-id/usb-1a86_USB_Single_Serial_5B90103298-if00 \
    --robot.id=so101_follower_white \
    "$@"
