# importation function
Import-Module ".\module\1-module-function-install-adds.psm1"
Import-Module ".\module\2-module-function-manage-fileshare.psm1"
Import-Module ".\module\3-module-function-import_objet-ad.psm1"

# variables
$ENTREE_DOMAIN = Read-Host("votre domaine sans le '.local' a la fin")
$ENTREE_IP_HOST = Read-Host("ip du serveur")
$ENTREE_IP_ROUTER = Read-Host("ip de passerelle")
$ENTREE_SAFE_PASSWORD = Read-Host("ip de passerelle")
$IMPORT_OU = ".\csv\OU.csv"
$IMPORT_GRP = ".\csv\GROUPS.csv"
$IMPORT_USER = ".\csv\USERS.csv"
$PATH_FILESHARE = "D:\partage"

# using function
Install-ADDS -DOMAINE_NAME $ENTREE_DOMAIN -IP_HOST $ENTREE_IP_HOST -IP_ROUTER $ENTREE_IP_ROUTER -SAFE_PASSWORD $ENTREE_SAFE_PASSWORD
Import-BulkOU -DOMAIN_NAME $ENTREE_DOMAIN -PATH_CSV $IMPORT_OU
Import-BulkGroup -DOMAIN_NAME $ENTREE_DOMAIN -PATH_CSV $IMPORT_GRP
Import-BulkUser -DOMAIN_NAME $ENTREE_DOMAIN -PATH_CSV $IMPORT_USER


New-Item -Name ($PATH_FILESHARE).Split('\')[-1] -ItemType Directory -Path ($PATH_FILESHARE).Split('\')[0]
Manage-FShare -Path $PATH_FILESHARE -GroupAccess "Utilisateurs du domaine"
Manage-FSAccess -PATH $PATH_FILESHARE -GROUPNAME "RBAC_SRVFL7501_ALL_R-X" -DESACTIVATEINHERITANCE $true -PRESERVEINHERITANCE $false -RIGHT "ReadAndExecute" -ACCESS_CONTROL "Allow"
Manage-FSAccess -PATH $PATH_FILESHARE -GROUPNAME "RBAC_SRVFL7501_ALL_RWX" -DESACTIVATEINHERITANCE $true -PRESERVEINHERITANCE $false -RIGHT "Write" -ACCESS_CONTROL "Allow"