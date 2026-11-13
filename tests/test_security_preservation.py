from pathlib import Path
import unittest

ROOT=Path(__file__).resolve().parents[1]

class SecurityPreservationTests(unittest.TestCase):
    def test_playbook_does_not_run_security_off_automatically(self):
        for path in (ROOT/'playbook/Configuration').rglob('*.yml'):
            self.assertNotIn('ErxckOS.Security.Disable.cmd',path.read_text(encoding='utf-8-sig'),str(path))

    def test_manual_security_toggle_preserves_security_interface(self):
        source=(ROOT/'app/Scripts/ErxckOS.Security.Disable.cmd').read_text()
        self.assertNotIn('SecurityHealthService',source)
        self.assertNotIn('wscsvc',source)
        self.assertNotIn('/v "SecurityHealth"',source)

    def test_playbook_preserves_restore_and_security_ui_configuration(self):
        source=(ROOT/'playbook/Configuration/features/erxckos/registry.yml').read_text()
        self.assertNotIn('disable-system-restore-pre-defined-config.yml',source)
        source=(ROOT/'playbook/Configuration/features/erxckos/registry/configure-deprovisioned-apps.yml').read_text()
        self.assertNotIn('Microsoft.SecHealthUI',source)
        source=(ROOT/'playbook/Configuration/features/erxckos/registry/configure-security.yml').read_text()
        self.assertNotIn("value: 'HideSystray'",source)
        self.assertNotIn("value: 'SecurityHealth', operation: delete",source)

if __name__=='__main__':unittest.main()
