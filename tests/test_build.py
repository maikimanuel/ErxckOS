import importlib.util
from pathlib import Path
import tempfile,unittest,hashlib,json
spec=importlib.util.spec_from_file_location('build',Path(__file__).resolve().parents[1]/'build.py')
class ReleaseTests(unittest.TestCase):
 def load_builder(self):
  self.assertTrue(Path(spec.origin).is_file(),'Falta el empaquetador de ErxckOS')
  mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod);return mod
 def test_repository_validation(self):
  mod=self.load_builder()
  self.assertEqual(mod.validate_repository('erxck/ErxckOS'),'erxck/ErxckOS')
  for value in ['https://github.com/x/y','../repo','x/y/z','x/$(command)','x/']:
   with self.assertRaises(ValueError):mod.validate_repository(value)
 def test_stamping_and_package_contents(self):
  mod=self.load_builder()
  import py7zr,xml.etree.ElementTree as ET,json
  with tempfile.TemporaryDirectory() as tmp:
   # Synthetic installer bytes exercise packaging only; Windows CI tests the real installer.
   installer=Path(tmp)/'fixture-setup.exe';installer.write_bytes(b'MZ\x00test-installer-fixture')
   installer.with_suffix('.json').write_text(json.dumps(dict(version=(Path(spec.origin).parent/'VERSION').read_text().strip(),repository='erxck/ErxckOS',sha256=hashlib.sha256(installer.read_bytes()).hexdigest())))
   destination=Path(tmp)/'dist'
   files=mod.build(destination,'erxck/ErxckOS',installer=installer)
   self.assertEqual({p.name for p in files},{'ErxckOS.apbx','SHA256SUMS.txt'})
   self.assertFalse(list(destination.glob('*.zip')))
   apbx=next(p for p in files if p.suffix=='.apbx')
   with py7zr.SevenZipFile(apbx,password='malte') as z:
    self.assertIn('playbook.conf',z.getnames());z.extractall(Path(tmp)/'unpacked')
   root=ET.parse(Path(tmp)/'unpacked/playbook.conf').getroot()
   self.assertEqual(root.findtext('Git'),'https://github.com/erxck/ErxckOS')
   self.assertEqual(root.findtext('Name'),'ErxckOS')
   software=(Path(tmp)/'unpacked/Configuration/features/erxckos/software.yml').read_text()
   self.assertNotIn('RevisionTool-Setup',software);self.assertNotIn('meetrevision',software)
   embedded=Path(tmp)/'unpacked/Executables/ErxckOS-Setup.exe'
   self.assertEqual(embedded.read_bytes(),installer.read_bytes())
   self.assertNotIn('robocopy "ErxckOS Tool"',software)
   self.assertIn('start "" /wait "ErxckOS-Setup.exe"',software)
   self.assertIn('/VERYSILENT',software)
   self.assertIn('wait: true',software)
   sums=(destination/'SHA256SUMS.txt').read_text().splitlines()
   self.assertEqual(sums,[hashlib.sha256(apbx.read_bytes()).hexdigest()+'  ErxckOS.apbx'])
 def test_missing_installer_fails_before_packaging(self):
  mod=self.load_builder()
  with tempfile.TemporaryDirectory() as tmp:
   with self.assertRaises(FileNotFoundError):
    mod.build(Path(tmp)/'out','erxck/ErxckOS',installer=Path(tmp)/'missing.exe')
   self.assertFalse((Path(tmp)/'out/ErxckOS.apbx').exists())
 def test_stale_or_changed_installer_is_rejected(self):
  mod=self.load_builder()
  with tempfile.TemporaryDirectory() as tmp:
   installer=Path(tmp)/'setup.exe';installer.write_bytes(b'MZ\x00fixture')
   valid=dict(version=(Path(spec.origin).parent/'VERSION').read_text().strip(),repository='erxck/ErxckOS',sha256=hashlib.sha256(installer.read_bytes()).hexdigest())
   for field,value in [('version','0.0.1'),('repository','other/repo'),('sha256','0'*64)]:
    with self.subTest(field=field):
     metadata=dict(valid);metadata[field]=value
     installer.with_suffix('.json').write_text(json.dumps(metadata))
     with self.assertRaises(ValueError):mod.build(Path(tmp)/'out','erxck/ErxckOS',installer=installer)
if __name__=='__main__':unittest.main()
