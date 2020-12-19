$OUNAMES = "Servers"
$TOPOU = "JAMHQ"


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