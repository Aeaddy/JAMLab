[CmdletBinding()]Param(
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
$SCCMCollectionName01 = "All Systems" #Deployment Limiting Collection
$SCCMCollectionName02 = "UnattendedInstall" #Deployment Collection
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
Write-Output "$UFORMATTEDDATE : $VMName : Validating the  Configuration Manager PowerShell module is present." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber

if ($env:SMS_ADMIN_UI_PATH) {
    Write-Output "$UFORMATTEDDATE : $VMName : Found Configuration Manager PowerShell module. Attempting to connect to the Configuration Manager environment to create prestaged computer object." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber

    $snip = $env:SMS_ADMIN_UI_PATH.Length-5
    $modPath = $env:SMS_ADMIN_UI_PATH.Substring(0,$snip)
    Import-Module "$modPath\ConfigurationManager.psd1"
    $SiteCode = Get-PSDrive -PSProvider CMSite
    Set-Location "$($SiteCode.Name):\"
    $PSD = $($SiteCode.Name)

    $CMConnectedSite = Get-CMSite -SiteCode $PSD

    if ($CMConnectedSite) {
        Write-Output "$UFORMATTEDDATE : $VMName : Successfully connected to the Configuration Manager site: $PSA." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
    }else{
        Write-Output "$UFORMATTEDDATE : $VMName : Error: Could not connect to the Configuration Manager site: $PSA." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
        #exit
    }       


}else{
    Write-Output "$UFORMATTEDDATE : $VMName : Error! Could not find or connect to the Configuration Manager PowerShell module." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
    #exit
}


#Import Computer Details to create an SCCM Prestaged Computer Object and add it to Windows Deployment Collection
Write-Output "$UFORMATTEDDATE : $VMName : Begin creatation of prestaged computer record in Configuration Manager in $SCCMCollectionName01 collection." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
Write-Output "$UFORMATTEDDATE : $VMName : Validating a computer record with the name $VMName does not exist in Configuration Manager." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
$CMDeviceExists0 = Get-CMDevice -Name $VMName
if (!$CMDeviceExists0) {
    
    #Importing computer record
    Import-CMComputerInformation -ComputerName $VMName -MacAddress $macaddr2 -CollectionName $SCCMCollectionName01
    Invoke-CMCollectionUpdate -Name $SCCMCollectionName01
    $CMDevice = Get-CMDevice -Name $VMName
    $C = 1
    while (!$CMDevice) {
        #write-output "Waiting for New Object to be popluated"
        $C = $C+1
        #write-output "$C"
        $CMDevice = Get-CMDevice -Name $VMName
        if ($C -eq "320") { 
        Write-Output "$UFORMATTEDDATE : $VMName : Error! It the device was not created in the Configuration Manager database." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
        #exit 
        }
    }

    #Validate computer record creation
    $CMDeviceExists1 = Get-CMDevice -Name $VMName
    if ($CMDeviceExists1) {

        Write-Output "$UFORMATTEDDATE : $VMName : Validated the computer record with the name $VMName was successfully created in Configuration Manager." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
        
        Write-Output "$UFORMATTEDDATE : $VMName : Attempting to add the computer record with the name $VMName to the $SCCMCollectionName02 collection in Configuration Manager." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
        Write-Output "$UFORMATTEDDATE : $VMName : Validating that the collection $SCCMCollectionName02 is available and that a device record with the name $VMName is not already a member." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber

        $CMCollExists0 = Get-CMDeviceCollection -Name $SCCMCollectionName02
        if ($CMCollExists0) {

            Write-Output "$UFORMATTEDDATE : $VMName : Successfully validated the collection $SCCMCollectionName02 exists in Configuration Manager.  Checking for device membership." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber

            $CMDevAdded0 = Get-CMDeviceCollectionDirectMembershipRule -CollectionName $SCCMCollectionName02 -ResourceName $VMName
            if (!$CMDevAdded0) {
                Write-Output "$UFORMATTEDDATE : $VMName : The collection does not contain the record $VMName.  Attempting to add the device to the collection." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
                Add-CMDeviceCollectionDirectMembershipRule -Resource $CMDevice -CollectionName $SCCMCollectionName02
                Write-Output "Device Added"
                Invoke-CMCollectionUpdate -Name $SCCMCollectionName02
                write-output "Updating Collection."
                while (!$CMDeviceInColl) {
                    write-output "Waiting for New Object to be popluated in the $SCCMCollectionName02 collection."
                    $C = $C+1
                    write-output "$C"
                    $CMDeviceInColl = Get-CMDevice -Name $VMName
                }

                Write-Output "$UFORMATTEDDATE : $VMName : Validating the device $VMName was added to device collection $SCCMCollectionName02." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
                $CMDevAdded1 = Get-CMDeviceCollectionDirectMembershipRule -CollectionName $SCCMCollectionName02 -ResourceName $VMName
                if ($CMDevAdded1) {
                    Write-Output "$UFORMATTEDDATE : $VMName : The device $VMName was successfully added to device collection $SCCMCollectionName02." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
                    Set-Location C:
                }else{
                    Write-Output "$UFORMATTEDDATE : $VMName : Error validating the device $VMName was added to device collection $SCCMCollectionName02." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
                    #exit
                }

            }else{
                 Write-Output "$UFORMATTEDDATE : $VMName : Error! A record for this device $VMName has been identified as a member of the collection $SCCMCollectionName02 or something else has gone wrong. Exiting script for further troubleshooting." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
                 #exit
            }

        }else{
            Write-Output "$UFORMATTEDDATE : $VMName : Error! Could not find a Device Collection with the name: $SCCMCollectionName02. Please validate manually." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
            #exit
        }

    }else{
        Write-Output "$UFORMATTEDDATE : $VMName : Error! Could not find the computer record with the name $VMName in Configuration Manager.  Please see the Configuration Manager logs for more details." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
        #exit        
    }

}else{
    Write-Output "$UFORMATTEDDATE : $VMName : Error! A computer record with the name $VMName was found in the Configuration Manager database. The computer record was not created." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
    #exit
}


#Create DVD Drive and Connect to VM with mounted ISO
Write-Output "$UFORMATTEDDATE : $VMName : Beginning creation of DVD drive on VM $VMName and mounting ISO file at: $BootFile" | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
Write-Output "$UFORMATTEDDATE : $VMName : Checking for DVD drive on VM $VMName." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
$VMDVDCheck0 = Get-VMDvdDrive -VMName $VMName
if (!$VMDVDCheck0) {
    Write-Output "$UFORMATTEDDATE : $VMName : Creating DVD drive on VM $VMName." | Out-File -FilePath $LOGPATH -Append -Force -NoClobber
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


