function Install-ADDS{
    param(
        [String]$DOMAINE_NAME
        [String]$IP_HOST
        [String]$IP_ROUTER
        [String]$SAFE_PASSWORD
    )
    New-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv4 -PrefixLength 24 -IPAddress $IP_HOS-DefaultGateway $IP_ROUTER
    Set-DnsClientDohServerAddress -ServerAddress ${IP_ROUTER}
    Import-Module ADDSDeployment
    Install-ADDSForest `
        -CreateDnsDelegation:$false `
        -DatabasePath "C:\WINDOWS\NTDS" `
        -DomainMode "Win2025" `
        -DomainName "${DOMAINE_NAME.ToUpper()}.local" `
        -DomainNetbiosName $DOMAINE_NAME `
        -ForestMode "Win2025" `
        -InstallDns:$true `
        -LogPath "C:\WINDOWS\NTDS" `
        -NoRebootOnCompletion:$false `
        -SysvolPath "C:\WINDOWS\SYSVOL" `
        -SafeModeAdministratorPassword (ConvertTo-SecureString $SAFE_PASSWORD -AsPlainText -Force) `
        -Force:$true
}

# Ex : Install-ADDS -DOMAINE_NAME "MonDomaine" -IP_HOST "192.168.1.20" -IP_ROUTER "192.168.1.20" -SAFE_PASSWORD "MyP@ssw0rd"