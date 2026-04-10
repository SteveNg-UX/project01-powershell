# import csv des OU
function Import-BulkOU{
    param(
        [String]$PATH_CSV,
        [String]$DOMAIN_NAME
    )
    $IMPORT_OU_CSV = Import-Csv -Delimiter ";" -Path $PATH_CSV
    New-ADOrganizationalUnit -Name $DOMAIN_NAME -Path $((Get-ADDomain).DistinguishedName) -ProtectedFromAccidentalDeletion $false
    Foreach ($ou_e in $IMPORT_OU_CSV) {
        # Dans le CSV colonne PATH : Si la valeur est vide, alors il se trouve dans OU=DOMAINE,DC=domaine,DC=local
        if($ou_e.PATH -eq "") {
            New-ADOrganizationalUnit -Name $ou_e.NAME `
                -Path "OU=${DOMAIN_NAME},$((Get-ADDomain).DistinguishedName)" `
                -ProtectedFromAccidentalDeletion $false
        }
        else {
            [String]$PATH_ADDS = $ou_e.PATH+",OU=${DOMAIN_NAME},$((Get-ADDomain).DistinguishedName)"
            New-ADOrganizationalUnit -Name $ou_e.NAME -Path $PATH_ADDS -ProtectedFromAccidentalDeletion $false
        }
    }
}

# import csv des groupes
function Import-BulkGroup{
    param(
        [String]$PATH_CSV
        [String]$DOMAIN_NAME
    )
    $IMPORT_GRP_CSV = Import-Csv -Delimiter ";" -Path $PATH_CSV
    Foreach ($grp_e in $IMPORT_GROUPS_CSV) {
        [String]$PATH_ADDS = $grp_e.PATH+",OU=${DOMAIN_NAME},$((Get-ADDomain).DistinguishedName)"
        New-ADGroup -Name $grp_e.NAME -GroupCategory "Security" -GroupScope $grp_e.SCOPE -Path $PATH_ADDS
    }
}

# import csv des utilisateurs
function Import-BulkUser{
    param(
        [String]$PATH_CSV
        [String]$DOMAIN_NAME
    )
    $IMPORT_GRP_CSV = Import-Csv -Delimiter ";" -Path $PATH_CSV
    foreach ($users_e in $CSV){
        [String]$NAME = $users_e.FIRSTNAME.Substring(0,1).ToUpper()+$users_e.FIRSTNAME.Substring(1).ToLower()+" "+$users_e.LASTNAME.ToUpper()
        [String]$SAMACOUNTNAME = $users_e.FIRSTNAME.ToLower()[0]+"."+$users_e.LASTNAME.ToLower()
        [String]$USERPRINCIPALNAME = $users_e.FIRSTNAME.ToLower()+"."+$users_e.LASTNAME.ToLower()+"@"+(Get-ADDomain).DNSRoot
        [String]$PATH_ADDS = $users_e.PATH+",OU="+$DOMAIN_NAME+","+$(Get-ADDomain).DistinguishedName
        New-ADUser -Name $NAME `
            -UserPrincipalName $USERPRINCIPALNAME `
            -SamAccountName $SAMACOUNTNAME `
            -AccountPassword $(ConvertTo-SecureString  $users_e.PASSWORD -AsPlainText -Force) `
            -Path $PATH_ADDS `
            -ChangePasswordAtLogon $true `
            -PasswordNeverExpires $false `
            -Enabled $true
    }
}