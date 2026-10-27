#!/usr/bin/env bash
set -euo pipefail

# Persistent USB identities confirmed by unplugging the black leader.
# Camera identities confirmed from live frames; MJPEG reduces USB capture bandwidth.
exec lerobot-teleoperate \
    --robot.type=so101_follower \
    --robot.port=/dev/serial/by-id/usb-1a86_USB_Single_Serial_5B90103298-if00 \
    --robot.id=so101_follower_white \
    --robot.cameras="{top: {type: opencv, index_or_path: /dev/v4l/by-id/usb-Web_Camera_Web_Camera_202512181-video-index0, width: 640, height: 480, fps: 30, rotation: 0, fourcc: MJPG}, wrist: {type: opencv, index_or_path: /dev/v4l/by-id/usb-Generic_USB_HD_Camera_200910120001-video-index0, width: 640, height: 480, fps: 30, rotation: 0, fourcc: MJPG}}" \
    --teleop.type=so101_leader \
    --teleop.port=/dev/serial/by-id/usb-1a86_USB_Single_Serial_5B90100708-if00 \
    --teleop.id=so101_leader_black \
    --display_data=true \
    "$@"
