import os
import subprocess

path = os.getcwd()
repository_name = os.path.basename(path)

if os.getcwd() == "rap_fr":
    repository_name = "ReaperAccessible scripts"
elif os.getcwd() == "rap_en":
    repository_name = "ReaperAccessible scripts US"

script = f"""git rm index.xml & \
reapack-index -w -n {repository_name} --no-commit & \
git add -A & \
git commit -m \"MAJ de l'index\" & \
git push
"""

subprocess.run(script, shell=True)
