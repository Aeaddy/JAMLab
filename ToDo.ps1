<#DeleteVM
Check VM
Delete Disk
Delete VM Object
Delete VMDir
Check in SCCM and MDT and cleanup
/#>

get-vm
$VMName = "SuseManager"

$currentVM = get-vm -Name $VMName
$currentVM.HardDrives
$currentVM.Path
$currentVM.VMName