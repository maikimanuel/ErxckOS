"""Build ErxckOS release files without executing any Windows changes."""
from pathlib import Path
import argparse,hashlib,json,re,shutil,tempfile,xml.etree.ElementTree as ET,zipfile
import py7zr,yaml
ROOT=Path(__file__).resolve().parent

def validate_repository(value):
    if not isinstance(value,str) or not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9-]*/[A-Za-z0-9_.-]+',value):
        raise ValueError('Usa el formato propietario/repositorio de GitHub')
    if value.split('/')[1] in {'.','..'}:raise ValueError('Nombre de repositorio no valido')
    return value

def validate_playbook(root):
    xml=ET.parse(root/'playbook.conf').getroot()
    assert xml.findtext('Name')=='ErxckOS'
    assert xml.findtext('Username')=='ErxckOS'
    for file in (root/'Configuration').rglob('*.yml'):
        node=yaml.compose(file.read_text(encoding='utf-8-sig'))
        if node:
            for key,val in node.value:
                if key.value=='features':
                    for entry in val.value:
                        ref=root/'Configuration'/entry.value.replace('\\','/')
                        if not ref.is_file():raise ValueError(f'Referencia no encontrada: {entry.value}')
        text=file.read_text(encoding='utf-8-sig')
        if 'RevisionTool-Setup' in text or 'meetrevision/revision-tool' in text:
            raise ValueError('Dependencia externa no eliminada')

def build(destination,repository=None):
    if repository:validate_repository(repository)
    destination=Path(destination);destination.mkdir(parents=True,exist_ok=True)
    version=(ROOT/'VERSION').read_text().strip()
    with tempfile.TemporaryDirectory() as temp:
        staging=Path(temp);pb=staging/'playbook';app=staging/'app'
        shutil.copytree(ROOT/'playbook',pb);shutil.copytree(ROOT/'app',app)
        for target in [app/'licenses',pb/'Executables/ErxckOS Tool/licenses']:
            shutil.copytree(ROOT/'licenses',target,dirs_exist_ok=True)
        config={'repository':repository,'version':version}
        (app/'update-config.json').write_text(json.dumps(config,indent=2),encoding='utf-8')
        shutil.copytree(app,pb/'Executables/ErxckOS Tool',dirs_exist_ok=True)
        doc=ET.parse(pb/'playbook.conf');root=doc.getroot();root.find('Version').text=version
        for tag in ['Git','Website','DonateLink','ProductCode']:
            for elem in list(root.findall(tag)):root.remove(elem)
        if repository:ET.SubElement(root,'Git').text='https://github.com/'+repository
        ET.indent(doc,space='    ');doc.write(pb/'playbook.conf',encoding='utf-8',xml_declaration=True)
        finalize=pb/'Executables/FINALIZE.cmd'
        text=finalize.read_text()
        text=re.sub(r'(?m)^set version=.*$', 'set version='+version, text)
        finalize.write_text(text)
        validate_playbook(pb)
        apbx=destination/'ErxckOS.apbx'
        with py7zr.SevenZipFile(apbx,'w',password='malte',header_encryption=True) as archive:
            for file in sorted(pb.rglob('*')):
                if file.is_file():archive.write(file,file.relative_to(pb).as_posix())
        zip_path=destination/'ErxckOS-Tool.zip'
        with zipfile.ZipFile(zip_path,'w',zipfile.ZIP_DEFLATED) as archive:
            for file in sorted(app.rglob('*')):
                if file.is_file():archive.write(file,'ErxckOS Tool/'+file.relative_to(app).as_posix())
        files=[apbx,zip_path]
        sums=destination/'SHA256SUMS.txt'
        sums.write_text(''.join(hashlib.sha256(p.read_bytes()).hexdigest()+'  '+p.name+'\n' for p in files),encoding='utf-8')
        return files+[sums]

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--repository');parser.add_argument('--output',default='dist')
    options=parser.parse_args()
    for result in build(Path(options.output),options.repository):print(result)
