build-ad-organisation



## Etape 1 : Téléchargement
```Powershell
# télécharger le fichier zip contenant le scripte
Invoke-WebRequest -Uri "https://gitlab.com/noxumbris/project01-powershell/build-ad-organisation/-/archive/main/build-ad-organisation-main.zip?ref_type=heads" -OutFile "$PSScriptRoot\build-ad-organisation.zip"

# déziper le scripte
Expand-Archive -LiteralPath "$PSScriptRoot\build-ad-organisation.zip" -DestinationPath "$PSScriptRoot\build-ad-organisation"

# supprimer le fichier zip
Remove-Item -Path "$PSScriptRoot\build-ad-organisation.zip"
```

---

## Etape 2 : Lancement
```Powershell
DPowershell
# se déplacer dans le dossier
cd "$PSScriptRoot\build-ad-organisation"

# lancer le scripte
.\setup.ps
```