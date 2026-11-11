from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class DeviceIntegrationTests(unittest.TestCase):
    def test_playbook_does_not_override_portable_power_policy(self):
        finalize = (ROOT / 'playbook/Executables/FINALIZE.cmd').read_text()
        self.assertNotIn('powercfg /hibernate off', finalize)
        self.assertNotIn('powercfg -s 3ff9831b', finalize)
        for path in (ROOT / 'playbook/Configuration').rglob('*.yml'):
            self.assertNotIn("value: 'HibernateEnabled'", path.read_text(encoding='utf-8-sig'), str(path))

    def test_app_and_playbook_share_profile_action(self):
        app = (ROOT / 'app/ErxckOS.ps1').read_text(encoding='utf-8-sig')
        config = (ROOT / 'playbook/Configuration/features/erxckos/config.yml').read_text()
        self.assertIn("'AutoPower'", app)
        self.assertIn('-Action AutoPower', config)
        self.assertIn('runas: currentUserElevated', config)


if __name__ == '__main__':
    unittest.main()
