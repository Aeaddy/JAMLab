[CmdletBinding()]Param(
    [Parameter( Position = 0, Mandatory = $true)]
    [String]$VMName,
    [Parameter( Position = 1, Mandatory = $true)]
    [ValidateSet('Server','Workstation')]
    [String]$VMType

)

If ($VMType -eq "Workstation") {

#Windows Client
$BootFile = "E:\Media\source files\OSD\Boot ISO\U_ZTI_SCCM_WinPE_ISO_1.iso"
$SCCMCollectionName01 = "All Systems"
$SCCMCollectionName02 = "UnattendedInstall"

#Create Virtual Machine - GEN2
New-VM -Name $VMName -MemoryStartupBytes 4096MB -Path "D:\Hyper-V\ConfigurationFiles\Virtual Machines" -Generation 2

#Create Virtual Disk
New-VHD -Path "D:\Hyper-V\Virtual Hard Disks\$VMName.vhdx" -SizeBytes 60GB -Dynamic

#Connect Virtual Disk to VM
Add-VMHardDiskDrive -VMName $VMName -Path "D:\Hyper-V\Virtual Hard Disks\$VMName.vhdx"

#Connect Network Adapter to Internal Network Switch
Connect-VMNetworkAdapter -VMName $VMName -SwitchName Internal

#Start and Stop VM to generate MAC Address
Start-VM –Name $VMName
start-sleep -Seconds 5
Stop-VM -Name $VMName -TurnOff

#Get and format MAC address from HyperV VM
$MacAddr = Get-VM -Name $VMName | Get-VMNetworkAdapter | select -ExpandProperty MacAddress
$macaddr2 = ($MacAddr | ForEach-Object {
    $_.Insert(2,":").Insert(5,":").Insert(8,":").Insert(11,":").Insert(14,":")
}) -join ' '

#Connect to SCCM Environment (This requires the SCCM PowerShell module and/or the SCCM Console.)
#Import the ConfigMgr PowerShell module & connect to ConfigMgr PSDrive
$snip = $env:SMS_ADMIN_UI_PATH.Length-5
$modPath = $env:SMS_ADMIN_UI_PATH.Substring(0,$snip)
Import-Module "$modPath\ConfigurationManager.psd1"
$SiteCode = Get-PSDrive -PSProvider CMSite
Set-Location "$($SiteCode.Name):\"
$PSD = $($SiteCode.Name)

#Import Computer Details to create an SCCM Prestaged Computer Object and add it to Windows Deployment Collection
Import-CMComputerInformation -ComputerName $VMName -MacAddress $macaddr2 -CollectionName $SCCMCollectionName01
Invoke-CMCollectionUpdate -Name $SCCMCollectionName01
$CMDevice = Get-CMDevice -Name $VMName
$C = 1
while (!$CMDevice) {
    write-output "Waiting for New Object to be popluated"
    $C = $C+1
    write-output "$C"
    $CMDevice = Get-CMDevice -Name $VMName
}
Add-CMDeviceCollectionDirectMembershipRule -Resource $CMDevice -CollectionName $SCCMCollectionName02
Invoke-CMCollectionUpdate -Name $SCCMCollectionName02

start-sleep -Seconds 5
Set-Location C:

#Create DVD Drive and Connect to VM with mounted ISO
Add-VMDvdDrive $VMName 
Set-VMDvdDrive -VMName $VMName -Path $BootFile
$VMCDRom = Get-VMDvdDrive -VMName $VMName

#Set Boot Order to DVDDrive
Set-VMFirmware -VMName $VMName -FirstBootDevice $VMCDRom

#Set Dynamic Memory Details
Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true -StartupBytes 4096MB -MinimumBytes 2148MB -MaximumBytes 4096MB

#Set Virtual Processor Count
Set-VMProcessor -VMName $VMName -Count 2
Start-VM –Name $VMName

}

If ($VMType -eq "Server") {

#Windows Server
$BootFile = "E:\Media\source files\OSD\Boot ISO\U_LiteTouchPE_x64.iso"

#Create Virtual Machine - GEN2
New-VM -Name $VMName -MemoryStartupBytes 4096MB -Path "D:\Hyper-V\ConfigurationFiles\Virtual Machines" -Generation 2

#Create Virtual Disk
New-VHD -Path "D:\Hyper-V\Virtual Hard Disks\$VMName.vhdx" -SizeBytes 60GB -Dynamic

#Connect Virtual Disk to VM
Add-VMHardDiskDrive -VMName $VMName -Path "D:\Hyper-V\Virtual Hard Disks\$VMName.vhdx"

#Connect Network Adapter to Internal Network Switch
Connect-VMNetworkAdapter -VMName $VMName -SwitchName Internal

#Set Dynamic Memory Details
Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true -StartupBytes 4096MB -MinimumBytes 2148MB -MaximumBytes 4096MB

#Start and Stop VM to generate MAC Address
Start-VM –Name $VMName
start-sleep -Seconds 5
Stop-VM -Name $VMName -TurnOff

#Connect to MDT Database
Import-Module C:\windows\system32\MDTDB.psm1 -ErrorAction Stop
Connect-MDTDatabase -sqlServer SQL1.jam.on -database MDT -ErrorAction stop

#Get and format MAC address from HyperV VM
$MacAddr = Get-VM -Name $VMName | Get-VMNetworkAdapter | select -ExpandProperty MacAddress
$macaddr2 = ($MacAddr | ForEach-Object {
    $_.Insert(2,":").Insert(5,":").Insert(8,":").Insert(11,":").Insert(14,":")
}) -join ' '

#Create a new entry in the MDT Database
new-mdtcomputer -macAddress $MacAddr2 -description $VMName -settings @{OSInstall='YES'; OSDComputerName=$VMName}

#Create DVD Drive and Connect to VM with mounted ISO
Add-VMDvdDrive $VMName 
Set-VMDvdDrive -VMName $VMName -Path $BootFile
$VMCDRom = Get-VMDvdDrive -VMName $VMName

#Set Boot Order to DVDDrive
Set-VMFirmware -VMName $VMName -FirstBootDevice $VMCDRom
#Set Virtual Processor Count
Set-VMProcessor -VMName $VMName -Count 4

#Start the VM
Start-VM –Name $VMName

}


