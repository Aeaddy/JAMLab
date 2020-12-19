$COMP = gc env:computername
$KEY = "VYNHK-YKQQV-JDDMP-6TY93-2WG34"
$ACTIVATE = get-wmiObject -query "select * from SoftwareLicensingService" -computername $COMP
$ACTIVATE.InstallProductKey($KEY)
$ACTIVATE.RefreshLicenseStatus()$NEWPCNAME = "CMSS1"$TZ = "Eastern Standard Time"$SVCS = "MapsBroker"Rename-Computer $NEWPCNAMESet-TimeZone -Id $TZstop-service $SVCforeach ($SVC in $SVCS) {Set-Service -Name $SVC -EA Stop -StartMode Disabled}Set-NetFirewallProfile -All -Enabled FalseEnable-PSRemoting start-sleep -Seconds 10

Restart-Computer