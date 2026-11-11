import importlib.util
from pathlib import Path
import tempfile,unittest,zipfile
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
   files=mod.build(Path(tmp),'erxck/ErxckOS')
   apbx=next(p for p in files if p.suffix=='.apbx')
   with py7zr.SevenZipFile(apbx,password='malte') as z:
    self.assertIn('playbook.conf',z.getnames());z.extractall(Path(tmp)/'unpacked')
   root=ET.parse(Path(tmp)/'unpacked/playbook.conf').getroot()
   self.assertEqual(root.findtext('Git'),'https://github.com/erxck/ErxckOS')
   self.assertEqual(root.findtext('Name'),'ErxckOS')
   software=(Path(tmp)/'unpacked/Configuration/features/erxckos/software.yml').read_text()
   self.assertNotIn('RevisionTool-Setup',software);self.assertNotIn('meetrevision',software)
   app=next(p for p in files if p.suffix=='.zip')
   with zipfile.ZipFile(app) as z:
    config=json.loads(z.read('ErxckOS Tool/update-config.json'))
    self.assertEqual(config['repository'],'erxck/ErxckOS')
    self.assertIn('ErxckOS Tool/ErxckOS.ps1',z.namelist())
    self.assertIn('ErxckOS Tool/Scripts/ErxckOS.Power.ps1',z.namelist())
    self.assertEqual(config['version'],(Path(spec.origin).parent/'VERSION').read_text().strip())
   self.assertTrue((Path(tmp)/'unpacked/Executables/ErxckOS Tool/Scripts/ErxckOS.Power.ps1').is_file())
if __name__=='__main__':unittest.main()
