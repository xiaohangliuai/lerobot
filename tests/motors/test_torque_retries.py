"""Regression coverage for communication failures during follower torque setup."""

import unittest
from unittest.mock import Mock, patch

from lerobot.motors import Motor, MotorNormMode
from lerobot.robots.so_follower.config_so_follower import SOFollowerRobotConfig
from lerobot.robots.so_follower.so_follower import SOFollower
from tests.mocks.mock_motors_bus import MockMotorsBus


class TestTorqueRetries(unittest.TestCase):
    def setUp(self) -> None:
        self.bus = MockMotorsBus(
            "/dev/dummy-port", {"gripper": Motor(6, "model_2", MotorNormMode.RANGE_0_100)}
        )
        self.bus.connect(handshake=False)
        self.addCleanup(self.bus.disconnect, disable_torque=False)

    def test_context_passes_retry_budget_and_restores_torque_on_error(self) -> None:
        with self.assertRaisesRegex(ValueError, "configuration failed"):
            with self.bus.torque_disabled(num_retry=2):
                self.assertEqual(self.bus._bus.stored(6, "torque_enable"), 0)
                raise ValueError("configuration failed")
        self.assertEqual(self.bus._bus.torques, [([6], False, 2), ([6], True, 2)])
        self.assertEqual(self.bus._bus.stored(6, "torque_enable"), 1)

    def test_persistent_failure_prevents_configuration(self) -> None:
        self.bus._bus.absent.add(6)
        with self.assertRaisesRegex(ConnectionError, "after 3 tries.*gripper"):
            with self.bus.torque_disabled(num_retry=2):
                self.fail("Configuration must not run when torque cannot be disabled")

    def test_follower_allows_retries_but_still_reports_persistent_failure(self) -> None:
        follower = object.__new__(SOFollower)
        follower.config = SOFollowerRobotConfig(port="/dev/dummy-port")
        follower.bus = self.bus
        follower.cameras = {}

        def transient_failure(ids: list[int], enabled: bool, retries: int = 0) -> dict[int, str]:
            return {6: "Operation timed out"} if enabled and retries < 2 else {}

        with (
            patch.object(self.bus, "configure_motors"),
            patch.object(self.bus, "set_operating_mode"),
            patch.object(self.bus, "write"),
            patch.object(self.bus._bus, "set_torque", side_effect=transient_failure) as torque,
        ):
            follower.configure()
            torque.assert_called_with([6], True, retries=2)
            torque.side_effect = None
            torque.return_value = {6: "Operation timed out"}
            with self.assertRaisesRegex(ConnectionError, "after 3 tries.*gripper"):
                follower.configure()

        # Avoid hardware cleanup on this deliberately uninitialized Robot instance.
        follower.disconnect = Mock()
