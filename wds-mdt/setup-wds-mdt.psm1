# ip static en 10.0.0.11/24
$IPv4_Interface	= $(Get-NetIPAddress | Where-Object AddressFamily -eq "IPv4" | Where-Object InterfaceAlias -NotLike "Loopback*").InterfaceIndex
Set-NetIPInterface -InterfaceIndex $IPv4_Interface -Dhcp Disabled
Set-NetIPAddress -IPAddress "10.0.0.11" -InterfaceIndex $IPv4_Interface -PrefixLength "24"
Set-NetIPInterface -InterfaceIndex $IPv4_Interface -Dhcp Disabled

# renommage serveur
Rename-Computer -NewName "srv-wds" ; Restart-Computer

# reduction lecteur C + creation lecteur E
$partitionC = Get-Partition -DriveLetter C
Resize-Partition -PartitionNumber $partitionC.PartitionNumber -DiskNumber $partitionC.DiskNumber -Size ($(Get-Volume -DriveLetter C).Size - 30GB)
$partitionWDS = New-Partition -DiskNumber $(Get-Disk -Partition $partitionC).Number -Size 30GB -AssignDriveLetter
Format-Volume -DriveLetter $partitionWDS.DriveLetter -FileSystem "NTFS" -NewFileSystemLabel "WDS"
Set-Partition -DriveLetter $partitionWDS.DriveLetter -NewDriveLetter "E"

# mise en domaine
Add-Computer -DomainName "ex.local" -Credential (Get-Credential) ; Restart-Computer

# installation & config wds
Install-WindowsFeature -IncludeManagementTools -Name WDS
Import-Module -Name "WDS"
New-Item -Path "E:\RemoteInstall" -ItemType Directory
WDSUTIL /Initialize-Server /RemInst:"E:\RemoteInstall"
Set-Service WDSServer -StartupType Automatic ; Start-Service WDSServer



# installation suite MDT
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2196127" -OutFile "C:\Users\Administrateur\Downloads\ADKSetup.exe"
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2196224" -OutFile "C:\Users\Administrateur\Downloads\ADKWinPESetup.exe"
Invoke-WebRequest -Uri "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi" -OutFile "C:\Users\Administrateur\Downloads\MicrosoftDeploymentToolkit_x64.msi"
Start-Process -FilePath "C:\Users\Administrateur\Downloads\ADKSetup.exe" -ArgumentList "/quiet" -Wait
Start-Process -FilePath "C:\Users\Administrateur\Downloads\ADKWinPESetup.exe" -ArgumentList "/quiet" -Wait
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i C:\Users\Administrateur\Downloads\MicrosoftDeploymentToolkit_x64.msi /quiet /norestart" -Wait

# pour eviter une erreur
New-Item -ItemType Directory -Path “C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\x86\WinPE_OCs"

# config suite MDT
New-Item -Path "E:\DeploymentShare" -ItemType directory
New-SmbShare -Name "DeploymentShare$" -Path "E:\DeploymentShare" -FullAccess Administrators
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
new-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root "E:\DeploymentShare" -Description "MDT Deployment Share" -NetworkPath "\\PDC2022\DeploymentShare$" -Verbose | add-MDTPersistentDrive -Verbose



# Conversion install.esd en install.wim depuis ISO monté
$driveletter_iso = $(Get-Volume | Where-Object "DriveType" -eq "CD-ROM").DriveLetter
if($(Get-Volume | Where-Object "DriveType" -eq "CD-ROM")){
    if(Test-Path -Path "${driveletter_iso}:\sources\install.esd"){
        $wimInfo = dism /Get-WimInfo /WimFile:"${driveletter_iso}:\sources\install.esd"
        if($wimInfo -match "Windows 11 Professionnel"){
            if(-not (Test-Path -Path "E:\imageconverted")){
                New-Item -ItemType Directory -Path "E:\imageconverted"
            }
            dism /export-image /SourceImageFile:${driveletter_iso}:\sources\install.esd /SourceIndex:6 /DestinationImageFile:E:\imageconverted\install.wim /Compress:max /CheckIntegrity
        }
        else{Write-Output("pas de windows pro")}
    }
    else{Write-Output("cdrom n'est pas un iso windows")}
}
else{Write-Output("pas de iso windows monté")}

# importation install.wim dans le E dans operating system du E:\DeploymentShare
#Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
#New-PSDrive -Name "DS001" -PSProvider MDTProvider -Root "E:\DeploymentShare"
import-mdtoperatingsystem -path "DS001:\Operating Systems" -SourceFile "E:\imageconverted\install.wim" -DestinationFolder "windows 11 pro" -Move -Verbose

# tache de deploiement
#Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
#New-PSDrive -Name "DS001" -PSProvider MDTProvider -Root "E:\DeploymentShare"
import-mdttasksequence -path "DS001:\Task Sequences" -Name "deploy windows 11" -Template "Client.xml" -Comments "" -ID "win11-01" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows 11 Pro in windows 11 pro install.wim" -FullName "Administrateur" -OrgName "ex.local" -HomePage "about:blank" -Verbose

# tache de capture
#Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
#New-PSDrive -Name "DS001" -PSProvider MDTProvider -Root "E:\DeploymentShare"
import-mdttasksequence -path "DS001:\Task Sequences" -Name "capture windows 11" -Template "CaptureOnly.xml" -Comments "" -ID "win11-02" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\Windows 11 Pro in windows 11 pro install.wim" -FullName "Administrateur" -OrgName "ex.local" -HomePage "about:blank" -Verbose

# update
#Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
#New-PSDrive -Name "DS001" -PSProvider MDTProvider -Root "E:\DeploymentShare"
update-MDTDeploymentShare -path "DS001:" -Force -Verbose

# importation image de demarrage dans WDS
Import-WdsBootImage -Path "E:\DeploymentShare\Boot\LiteTouchPE_x64.wim" -NewImageName "Windows 11"
Restart-Service WDSServer