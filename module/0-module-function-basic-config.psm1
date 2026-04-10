function Config-Server {
    param(
        [String]$NAMESERVER,
        [String]$IP_HOST,
        [String]$MASK_CIDR,
        [String]$IP_ROUTER
    )
    Rename-Computer -NewName $NAMESERVER -Restart
    New-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily "IPv4" -PrefixLength $MASK_CIDR -IPAddress $IP_HOST -DefaultGateway $IP_ROUTER
    Set-DnsClientDohServerAddress -ServerAddress $IP_ROUTER
}

# Ex : Config-Server -NAMESERVER "Nom-Serveur" -IP_HOST "192.168.1.10" -MASK_CIDR 24 -IP_ROUTER "192.168.1.1"