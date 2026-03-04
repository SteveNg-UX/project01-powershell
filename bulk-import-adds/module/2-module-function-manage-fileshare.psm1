function Manage-FSAccess {
    param(
        [string]$PATH,
        [string]$GROUPNAME,
        [bool]$DESACTIVATEINHERITANCE = $false,
        [bool]$PRESERVEINHERITANCE = $false,
        [ValidateSet("ReadAndExecute", "Write", "FullControl")][string]$RIGHT = "ReadAndExecute",
        [ValidateSet("Allow", "Deny")][string]$ACCESS_CONTROL = "Allow"
    )
    $acl = Get-Acl -Path $PATH
    $acl.SetAccessRuleProtection($DESACTIVATEINHERITANCE, $PRESERVEINHERITANCE)
    [System.Security.Principal.SecurityIdentifier]$GROUP = (Get-ADGroup -Identity $GROUPNAME).SID.Value
    try{
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $GROUP, $RIGHT,
            "ContainerInherit, ObjectInherit",
            "None",
            $ACCESS_CONTROL
        )
        $acl.SetAccessRule($rule)
        Set-Acl -Path $PATH -AclObject $acl
    }
    catch{
        Write-Host($_.Exception.Message)
    }
}


function Manage-FShare{
    param(
        [string]$Path,
        [string]$GroupAccess
    )
    New-SmbShare `
        -Name ($Path).Split('\')[-1] `
        -Path $Path `
        -ChangeAccess (Get-ADGroup -Identity $GroupAccess).SamAccountName `
        -FolderEnumerationMode AccessBased `
        -EncryptData $true
}