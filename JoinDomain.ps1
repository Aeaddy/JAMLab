﻿$ADID0 = "jam\administrator"
Add-Computer -DomainName "jam.on" -Credential $ADID3

start-sleep -Seconds 3

Restart-Computer