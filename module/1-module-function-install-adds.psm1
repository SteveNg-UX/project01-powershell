function Install-ADDS{
    param(
        [String]$DOMAINE_NAME,
        [String]$SAFE_PASSWORD
    )
    Add-WindowsFeature -Name "AD-Domain-Services", "DNS", "RSAT-AD-Tools", "RSAT-RemoteAccess", "GPMC" -IncludeAllSubFeature
    Import-Module ADDSDeployment
    Install-ADDSForest `
        -CreateDnsDelegation:$false `
        -DatabasePath "C:\WINDOWS\NTDS" `
        -DomainMode "Win2025" `
        -DomainName "$(DOMAINE_NAME.ToLower()).local" `
        -DomainNetbiosName "$DOMAINE_NAME.ToUpper()" `
        -ForestMode "Win2025" `
        -InstallDns:$true `
        -LogPath "C:\WINDOWS\NTDS" `
        -NoRebootOnCompletion:$false `
        -SysvolPath "C:\WINDOWS\SYSVOL" `
        -SafeModeAdministratorPassword (ConvertTo-SecureString $SAFE_PASSWORD -AsPlainText -Force) `
        -Force:$true
}

# Ex : Install-ADDS -DOMAINE_NAME "MonDomaine" -SAFE_PASSWORD "MyP@ssw0rd"