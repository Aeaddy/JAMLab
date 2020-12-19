﻿[CmdletBinding()]Param(
    [Parameter( Position = 0, Mandatory = $true)]
    [String]$VMName,
    [Parameter( Position = 1, Mandatory = $true)]
    [ValidateSet('Server','Workstation')]
    [String]$VMType

)

$VMName = "Win10-010"

#Configure Logging
$LOGDIR = $env:TEMP
$FORMATTEDDATE = Get-Date -format "MM-dd-yy"
$UFORMATTEDDATE = get-date
$LOGFILE = $VMName + "_" + $FORMATTEDDATE + ".log"
$LOGPATH = "$LOGDIR\$LOGFILE"
$LOGTEST = Test-Path $LOGPATH
If ($LOGTEST -eq $false) {
    New-Item -Path $LOGDIR -Name $LOGFILE -Force
}

Write-Output "********Begin Logging $UFORMATTEDDATE********" | out-file $LOGPATH -Append -Force -NoClobber 

#Clear logs older than 6 days
Get-ChildItem $LOGDIR -Recurse -File | Where CreationTime -lt  (Get-Date).AddDays(-6)  | Remove-Item -Force

#Windows Client
If ($VMType -eq "Workstation") {

Write-Output "$UFORMATTEDDATE : $VMName : Beginning creation and setup of new HyperV virtual workstation running Windows 10." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber

#Workstation details
$BootFile = "E:\Media\source files\OSD\Boot ISO\U_ZTI_SCCM_WinPE_ISO_1.iso"
$SCCMCollectionName01 = "All Systems"
$SCCMCollectionName02 = "UnattendedInstall"
Write-Output "$UFORMATTEDDATE : $VMName : The Boot file being used is: $BootFile" | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
Write-Output "$UFORMATTEDDATE : $VMName : The Device is going to be added created in MEMCM and added to the MEMCM Collections: $SCCMCollectionName01 and $SCCMCollectionName02 for OS Imaging." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber


#Check for Boot file
Write-Output "$UFORMATTEDDATE : $VMName : Validating the boot file exists." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber

if (Test-Path -Path $BootFile) {
    Write-Output "$UFORMATTEDDATE : $VMName : Successfully validated the boot file is available." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
}else{
    Write-Output "$UFORMATTEDDATE : $VMName : Error! The boot file was not found. Please validate the boot file path." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
    #exit   
}

#Begin VM creation
Write-Output "$UFORMATTEDDATE : $VMName : Begin creation of the Gen2 HyperV virtual machine." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
Write-Output "$UFORMATTEDDATE : $VMName : Checking to see if VM exists." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber

#Checking to see if VM exists
$VMExists0 = get-vm -Name $VMName
if (!$VMExists0) {

    Write-Output "$UFORMATTEDDATE : $VMName : Warning. VM $VMName does not exist. Beginning creation of vm: $VMName." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
    #Create Virtual Machine - GEN2
    New-VM -Name $VMName -MemoryStartupBytes 4096MB -Path "D:\Hyper-V\ConfigurationFiles\Virtual Machines" -Generation 2

    $VMExists1 = get-vm -Name $VMName
    if (!$VMExists1) {
        Write-Output "$UFORMATTEDDATE : $VMName : Error! Cannot create the virtual machine. Please see HyperV event logs for more details." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
        #exit
    }else{
        Write-Output "$UFORMATTEDDATE : $VMName : A new virtual machine was successfully created." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
    }

}


#Create Virtual Disk
$VHDPath = "D:\Hyper-V\Virtual Hard Disks\$VMName.vhdx"
Write-Output "$UFORMATTEDDATE : $VMName : Checking to see if a VHD file already exists with the name $VMName.vhdx." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
$VHDExists0 = Get-VHD -Path $VHDPath
if (!$VHDExists0) {
    Write-Output "$UFORMATTEDDATE : $VMName : Creating a new 60 GB virtual disk." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
    New-VHD -Path $VHDPath -SizeBytes 60GB -Dynamic
    $VHDExists1 = Get-VHD -Path $VHDPath
    if (!$VHDExists1) {
        Write-Output "$UFORMATTEDDATE : $VMName : Error! A virtual hard disk was not created. Please see HyperV event logs for more details." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
        #exit
    }else{
        Write-Output "$UFORMATTEDDATE : $VMName : A virtual hard disk was created in the following location: $VHDPath." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
    }
}else{
    Write-Output "$UFORMATTEDDATE : $VMName : Error! A VHD file already exists with the name ""$VMName.vhdx""." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
    #exit
}


#Connect Virtual Disk to VM
$VHDConnect0 = Get-VMHardDiskDrive -VMName $VMName
Write-Output "$UFORMATTEDDATE : $VMName : Checking to see if the virtual virtual disk ""$VMName.vhdx"" is connected to this VM." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
if (!$VHDConnect0) {
    Write-Output "$UFORMATTEDDATE : $VMName : A virtual disk is not connected to this VM.  Connecting the virtual disk at path: $VHDPath." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
    Add-VMHardDiskDrive -VMName $VMName -Path $VHDPath
    $VHDConnect = Get-VMHardDiskDrive -VMName $VMName

    if (!$VHDConnect) {
        Write-Output "$UFORMATTEDDATE : $VMName : Error! The virtual machine has no virtual disks connected." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
        #exit
    }else{

        $VHDControllerNum = $VHDConnect.ControllerNumber
        $VHDControllerLoc = $VHDConnect.ControllerLocation

        if ($VHDControllerNum -eq "0" -and $VHDControllerLoc -eq "0") {
            Write-Output "$UFORMATTEDDATE : $VMName : The virtual disk was successfully connected to the virtual machine as SCSI disk 0." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
        }

    }
}else{
    Write-Output "$UFORMATTEDDATE : $VMName : Error! The virtual machine has no virtual disks connected." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
}


#Connect Network Adapter to Internal Network Switch
Write-Output "$UFORMATTEDDATE : $VMName : Connecting the virtual network adapter to the Internal switch." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
Connect-VMNetworkAdapter -VMName $VMName -SwitchName Internal
$VMNetConnect = Get-VMNetworkAdapter -VMName $VMName
$VMNetConnectSwitch = $VMNetConnect.SwitchName
if (!$VMNetConnectSwitch) {
    Write-Output "$UFORMATTEDDATE : $VMName : Error! There is no switch associated to the virtual network adapter." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
    #exit
}else{
    if ($VMNetConnectSwitch -eq "internal") {
        Write-Output "$UFORMATTEDDATE : $VMName : The virtual network adapter has the ""Internal"" switch defined successfully." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
    }else{
        Write-Output "$UFORMATTEDDATE : $VMName : Error! There is a virtual switch defined, but it is not internal. The switch that it is connected to is $VMNetConnectSwitch. Please troubleshoot manually." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
        #exit
    }
}
    

#Start and Stop VM to generate MAC Address
Write-Output "$UFORMATTEDDATE : $VMName : Beginning the process of generating a valid MAC address." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
$MacAddr = Get-VM -Name $VMName | Get-VMNetworkAdapter | select -ExpandProperty MacAddress
if ($MacAddr -eq "000000000000") {
    Write-Output "$UFORMATTEDDATE : $VMName : The current MAC address is 00:00:00:00:00:00." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
    Start-VM –Name $VMName
    $d = "."
    while ($MacAddr -eq "000000000000") {
        $d = $d + "."
        start-sleep -Seconds 1
        $MacAddr = Get-VM -Name $VMName | Get-VMNetworkAdapter | select -ExpandProperty MacAddress
        Write-Output "$UFORMATTEDDATE : $VMName : Waiting for the VM to boot and generate a valid MAC address$d" | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
    }

    #Format the MAC address from HyperV VM
    $macaddr2 = ($MacAddr | ForEach-Object {
        $_.Insert(2,":").Insert(5,":").Insert(8,":").Insert(11,":").Insert(14,":")
    }) -join ' '

    Write-Output "$UFORMATTEDDATE : $VMName : A valid MAC address has been generated for the VM: $macaddr2" | Out-File -FilePath $LOGPATH -Append -Force -NoClobber

    Stop-VM -Name $VMName -TurnOff

}else{
    if ($MacAddr) {
        #Format the MAC address from HyperV VM
        $macaddr2 = ($MacAddr | ForEach-Object {
            $_.Insert(2,":").Insert(5,":").Insert(8,":").Insert(11,":").Insert(14,":")
        }) -join ' '
        Write-Output "$UFORMATTEDDATE : $VMName : The MAC address $macaddr2." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
    }else{
        Write-Output "$UFORMATTEDDATE : $VMName : There seems to be some problems with the MAC address.  Please troubleshoot manually." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
        #exit
    }
}


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

