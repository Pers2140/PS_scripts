#Enter New User Information First and Last Names
$newName= Read-Host -Prompt 'type the name of the user '
$firstname,$lastname = $newName.split(" ");
$aduser = $firstname[0]+$lastname;
$aduserobj = ( Get-aduser -identity $aduser )

# Disable user 
Disable-ADAccount -Identity $aduser
write-host "`n Finished disabling user ...`n"

# State/Province contents deleted
Set-ADUser -Identity $aduser -State ' '
write-host "`n State/Province contents deleted ... `n"

# Change title,Department,Company to 'Term'
Set-ADUser -Identity $aduser -Replace @{title="Term";department="Term";Company="Term"}
write-host "`n Changed Title,Department,Company to 'Term' ...`n"

# Clear Manager attribute
 Set-ADUser -Identity "$aduser" -Manager $null
 write-host "`n Cleared Manager attribute ...`n"

#  Remove all security groups except Domain users
$ADUser = Get-ADUser -Identity $aduser -Properties memberOf
ForEach ($Group In $ADUser.memberOf)
{
    Remove-ADGroupMember -Identity $Group -Members $ADUser
}
write-host "`n Removed all security groups except Domain users ...`n"

# Hide account from address list
Set-ADUser -Identity $aduser -replace @{msExchHideFromAddressLists=$true}
write-host "`n Hid account from address list ...`n"

# Move AD object to OU “TERM Converted to Shared Mailbox”
Move-ADObject -Identity $aduserobj.ObjectGUID -TargetPath 'OU="TERM Converted to Shared Mailbox",OU="Termination prep and on leave",DC=MNA,DC=local'
write-host "`n Move AD object to | OU TERM Converted to Shared Mailbox | ...`n"

# Connect to exchange to convert mailbox
Connect-ExchangeOnline -UserPrincipalName VitalMSP@montenidoaffiliates.com
Set-Mailbox "$newName" -type Shared

write-host "`n Remove licenses and disable account manually `n"
write-host "`n Remove user from Sharefile => https://montenido.sharefile.com/ `n"
