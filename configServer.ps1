﻿$COMP = gc env:computername
$KEY = "VYNHK-YKQQV-JDDMP-6TY93-2WG34"
$ACTIVATE = get-wmiObject -query "select * from SoftwareLicensingService" -computername $COMP
$ACTIVATE.InstallProductKey($KEY)
$ACTIVATE.RefreshLicenseStatus()

Restart-Computer