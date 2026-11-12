from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class DeviceIntegrationTests(unittest.TestCase):
    def test_installer_uses_elevated_user_and_persistent_log(self):
        import yaml
        source = (ROOT / 'playbook/Configuration/features/erxckos/software.yml').read_text()
        document = dict((key.value, value) for key, value in yaml.compose(source).value)
        for action in document['actions'].value:
            fields = dict((key.value, value.value) for key, value in action.value)
            if 'ErxckOS-Setup.exe' in fields.get('command', ''):
                self.assertEqual(action.tag, '!cmd:')
                self.assertEqual(fields.get('runas'), 'currentUserElevated')
                self.assertIn('start "" /wait "ErxckOS-Setup.exe"', fields['command'])
                self.assertIn('/LOG="%ProgramData%\\ErxckOS-Setup.log"', fields['command'])
                self.assertEqual(fields['wait'], 'true')
                codes = dict((k.value, v.value) for k, v in fields['handleExitCodes'])
                self.assertEqual(codes['!0'], 'halt')
                break
        else:
            self.fail('Falta el instalador integrado en las acciones de AME.')

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
