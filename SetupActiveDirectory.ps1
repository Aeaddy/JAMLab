$TOPOU = "JAMHQ"
$ADGROUPS = "CMAdmins", "CMUsers", "CMServers"
$ADUSERS = "CMUser1", "CMUser2", "CMUser3"
$ADUSERS1 = "CMAdmin1", "CMAdmin2", "CMAdmin3" "CMReporting", "CMNetAccess", "ADJoin", "CMClientPush"
$CMSERVERS = "CM1", "SQL1", "MDT1", "CMSS1"


$OUNAME1 = $TOPOU
New-ADOrganizationalUnit -Name $OUNAME1 -PassThru

$OUNAMES2 = "Dev", "Prod"
$OUPATH2 = "OU=$TOPOU,DC=jam,DC=on"
Foreach ($OUNAME2 in $OUNAMES2) {
New-ADOrganizationalUnit -Name $OUNAME2 -Path $OUPATH2 -PassThru
}

$OUNAMES3 = "AP", "EMEA", "NA"
$OUPATH3 = "OU=Prod,OU=$TOPOU,DC=jam,DC=on"
Foreach ($OUNAME3 in $OUNAMES3) {
New-ADOrganizationalUnit -Name $OUNAME3 -Path $OUPATH3 -PassThru
}

$OUNAMES4 = "AP", "EMEA", "NA"
$OUPATH4 = "OU=Dev,OU=$TOPOU,DC=jam,DC=on"
Foreach ($OUNAME4 in $OUNAMES4) {
New-ADOrganizationalUnit -Name $OUNAME4 -Path $OUPATH4 -PassThru
}

$OUNAMES = "Users", "Desktops", "Laptops", "Exclusions", "Servers"

$OUPATH = "OU=NA,OU=Prod,OU=$TOPOU,DC=jam,DC=on"
Foreach ($OUNAME in $OUNAMES) {
New-ADOrganizationalUnit -Name $OUNAME -Path $OUPATH -PassThru
}

$OUPATH = "OU=EMEA,OU=Prod,OU=$TOPOU,DC=jam,DC=on"
Foreach ($OUNAME in $OUNAMES) {
New-ADOrganizationalUnit -Name $OUNAME -Path $OUPATH -PassThru
}
$OUPATH = "OU=AP,OU=Prod,OU=$TOPOU,DC=jam,DC=on"
Foreach ($OUNAME in $OUNAMES) {
New-ADOrganizationalUnit -Name $OUNAME -Path $OUPATH -PassThru
}
$OUPATH = "OU=NA,OU=Dev,OU=$TOPOU,DC=jam,DC=on"
Foreach ($OUNAME in $OUNAMES) {
New-ADOrganizationalUnit -Name $OUNAME -Path $OUPATH -PassThru
}
$OUPATH = "OU=EMEA,OU=Dev,OU=$TOPOU,DC=jam,DC=on"
Foreach ($OUNAME in $OUNAMES) {
New-ADOrganizationalUnit -Name $OUNAME -Path $OUPATH -PassThru
}


$OUPATH = "OU=AP,OU=Dev,OU=$TOPOU,DC=jam,DC=on"
Foreach ($OUNAME in $OUNAMES) {
New-ADOrganizationalUnit -Name $OUNAME -Path $OUPATH -PassThru
}


#$ADGROUPS = "CMAdmins", "CMUsers", "CMServers"
foreach ($ADGROUP in $ADGROUPS) {
New-ADGroup -Name $ADGROUP -Path "OU=$TOPOU,DC=jam,DC=on" -GroupScope Global -PassThru
}

Add-ADGroupMember "CMadmins" "CMservers"
#$ADUSERS = "CMUser1", "CMUser2", "CMUser3"foreach ($ADUSER in $ADUSERS) {New-ADUser ` -Name $ADUSER ` -Path  "OU=$TOPOU,DC=jam,DC=on" ` -SamAccountName  $ADUSER ` -DisplayName "$ADUSER" ` -UserPrincipalName "$ADUSER@jam.on" ` -AccountPassword (ConvertTo-SecureString "Password123" -AsPlainText -Force) ` -PasswordNeverExpires $true ` -CannotChangePassword $true ` -Enabled $true ` -PassThruAdd-ADGroupMember "CMUsers" "$ADUSER";}#$ADUSERS1 = "CMAdmin1", "CMAdmin2", "CMadmin3"foreach ($ADUSER1 in $ADUSERS1) {New-ADUser ` -Name $ADUSER1 ` -Path  "OU=$TOPOU,DC=jam,DC=on" ` -SamAccountName  $ADUSER1 ` -DisplayName "$ADUSER1" ` -UserPrincipalName "$ADUSER1@jam.on" ` -AccountPassword (ConvertTo-SecureString "Password123" -AsPlainText -Force) ` -PasswordNeverExpires $true ` -CannotChangePassword $true ` -Enabled $true ` -PassThruAdd-ADGroupMember "CMAdmins" "$ADUSER1";}#$CMSERVERS = "CM1", "SQL1", "MDT1", "CMSS1"foreach ($CMSERVER in $CMSERVERS) {$CMSERVERPATH = "CN=$CMSERVER,CN=Computers,DC=jam,DC=on"Add-ADGroupMember "CMservers" $CMSERVERPATH -PassThru}