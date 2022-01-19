#Enter New User Information First and Last Names
$Newname = Read-Host -Prompt 'type the name of the user '
$newfirst,$newlast = $newname.split(" ");
$newaduser = $newfirst[0]+$newlast;

#compose the password
$fletter = $newfirst[0];
$numbers = ( Get-Random -Minimum 0 -Maximum 9999 ).ToString('0000');
write-host User Password is: $fletter$numbers'uc#00';


#Create the User in AD
$newuser = New-ADUser `
-Name $newaduser `
-GivenName $newfirst  `
-Surname $newlast `
-DisplayName $Newname `
-UserPrincipalName $newaduser@componenthardware.com `
-AccountPassword (Read-Host -AsSecureString "Input User Password") `
-Enabled $True;


#Enter the User to be copied information First and Last Name
$oldname = Read-Host -Prompt 'type the name of the user to copy';
$oldfirst,$oldlast = $oldname.split(" ");
$olduser = $oldfirst[0]+$oldlast


#Copy the information from the old user to copy into the new user 
$user = Get-ADUser -Filter "GivenName -eq '$oldfirst' -and Surname -eq '$oldlast'" -Properties * ;
$Company = $user.Company;
$title = $user.Title;
$off = $user.Office;
$tel = $user.telephoneNumber;
$dept = $user.Department;
$desc = $user.Description;
$co = $user.country;
$st = $user.state;
$man = $user.Manager
Set-ADUser $newaduser -Company $Company;  
Set-ADUser $newaduser -Office $off;
Set-ADUser $newaduser -State $st;
Set-ADUser $newaduser -Country $co ;
Set-ADUser $newaduser -Manager $man; 
Set-ADUser $newaduser -Title $title ;
Set-ADUser $newaduser -telephoneNumber $tel;
Set-ADUser $newaduser -Department $dept;
Set-ADUser $newaduser -Description $desc;
set-aduser $newaduser -city $city;
Set-ADUser $newaduser -StreetAddress $address;
Set-ADUser $newaduser -State $state;
Set-ADUser $newaduser -EmailAddress $newaduser'@componenthardware.com';

#copy groups
Get-ADUser -Identity $olduser -Properties memberof | Select-Object -ExpandProperty memberof |  Add-ADGroupMember -Members $newaduser

#move the new user into the correct OU
$targetDN = get-aduser -identity $olduser | Select-Object -ExpandProperty DistinguishedName
get-aduser $newaduser | Move-ADObject -TargetPath $TARGETDN.substring($targetDN.IndexOf("OU="))


#Rename the User
Set-ADUser $newaduser -PassThru | Rename-ADObject -NewName $Newname;


$email = get-aduser $newaduser | select-object -ExpandProperty userprincipalname

#create user mailbox in 365
#install O365 module
#Install-Module -Name ExchangeOnlineManagement
#Install-Module MSOnline
Connect-ExchangeOnline -UserPrincipalName cspiadmin@componenthardware.com
Write-Host "ConnectingGet-MsolUser -ReturnDeletedUsers to Office365..."
write-host "creating email address"
write-host User Password is: $fletter$numbers'uc#00';

New-Mailbox -Alias $newaduser `
-Name $newfirst `
-FirstName $newfirst `
-LastName $newlast `
-DisplayName "$Newname" `
-MicrosoftOnlineServicesID $newaduser@componenthardware.com `
-Password (Read-Host -AsSecureString "Input User Password") `
-ResetPasswordOnNextLogon $False;

#resize mailbox to 10 GB
$emailQuota = 10
write-host "Changing Office365 Email User Quota to "  $emailQuota  "GB"
$WarningQuota = $emailQuota - 5 
Set-Mailbox $newaduser@componenthardware.com -UseDatabaseQuotaDefaults $False -ProhibitSendReceiveQuota $emailQuota"GB" -ProhibitSendQuota $emailQuota"GB" -IssueWarningQuota $WarningQuota"GB"
Write-Host "Done"
#Set-MsolUserPrincipalName -UserPrincipalName $newaduser@componenthardware.com -NewUserPrincipalName $newaduser@chgonline.com

#Enable Archiving
Enable-Mailbox -Identity $newaduser –Archive

#add contact info in O365
$365user = Get-ADUser -identity $newaduser -Properties *
$o365title = $365user.Title;
$o365dept = $365user.Department;
Set-MsolUser -UserPrincipalName $email -Title $o365title -Department $o365dept

#set retention policy CHG Default
Set-Mailbox $newaduser -RetentionPolicy "CHG Default"

#remove chgusa.onmicrosoft.com
$remove = $newaduser+'@chgusa.onmicrosoft.com';
$add = $newaduser+'@chgonline.com';
Get-Mailbox $email | select -ExpandProperty emailaddresses | Select-String -Pattern "smtp"
Set-Mailbox $email -EmailAddresses @{Remove= $remove };
set-mailbox $email -EmailAddresses @{add= $add }

#add sip address
#$mbx = Get-Mailbox $newaduser
#$mbx.EmailAddresses +="eum:tsmit@contoso.com;phone-context=MyDialPlan.contoso.com"
#Set-Mailbox tony.smith -EmailAddresses $mbx.EmailAddresses

#add Sharepoint
# autopass
$User = "chgservice@componenthardware.com"
$Pass = "Secure_1890"
$LiveCred= New-Object System.Management.Automation.PsCredential($User,(ConvertTo-SecureString $Pass -AsPlainText -Force))
Import-Module MSOnline #-Verbose
Connect-MsolService -Credential $LiveCred

#add New User to group chg Shared Members
$AdminCenterURL  = "https://chgusa-admin.sharepoint.com" 
Connect-SPOService -url $AdminCenterURL -Credential $LiveCred
Request-SPOPersonalSite -UserEmails $email -NoWait
Start-Sleep -Seconds 120
Add-SPOUser -site https://chgusa.sharepoint.com -LoginName $email -Group "chg Shared Members"
Write-Host = "User " $newaduser "added to sharepoint group chg Shared Members"

write-host "created onedrive for " $newaduser
write-host "expanding one drive to 100GB"
$lastpart = $newaduser.ToLower()+'_componenthardware_com'
$OneDriveSite = 'https://chgusa-my.sharepoint.com/personal/'+$lastpart
set-sposite -Identity $OneDriveSite -StorageQuota 102400

#Create Scans Folder on VM-USE-03
New-Item -Path  \\VM-USE-03\c$\SCANS\$newaduser  -ItemType Directory
write-host "Created folder in  VM-use-03\C\Scans\$newaduser"

write-host "login to give the user a license"

#login to the user profile
[system.Diagnostics.Process]::Start("chrome","https://portal.office.com")


#Write-Host "Open OneDrive Script now to change OneDrive settings"