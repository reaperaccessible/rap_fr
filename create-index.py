import os
import subprocess


path = os.getcwd()
repository_name = os.path.basename(path)

if os.getcwd() == "rap_fr":
    repository_name = "ReaperAccessible scripts"
elif os.getcwd() == "rap_en":
    repository_name = "ReaperAccessible scripts US"

subprocess.run('git rm index.xml', shell=True)
subprocess.run(f'reapack-index -w -n {repository_name} --no-commit', shell=True)
subprocess.run('', shell=True)
subprocess.run('git add -A', shell=True)
subprocess.run('git commit -m "MAJ du fichier index"', shell=True)
subprocess.run('git push', shell=True)
