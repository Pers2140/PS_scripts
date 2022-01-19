#delete users from deleted users
$User = "chgservice@componenthardware.com"
$Pass = "Secure_1890"
$LiveCred= New-Object System.Management.Automation.PsCredential($User,(ConvertTo-SecureString $Pass -AsPlainText -Force))
Import-Module MSOnline #-Verbose
Connect-MsolService -Credential $LiveCred
Get-MsolUser -ReturnDeletedUsers
Remove-MsolUser -UserPrincipalName HCruz@componenthardware.com -RemoveFromRecycleBin

#get a list of personal sites
$User = "chgservice@componenthardware.com"
$Pass = "Secure_1890"
$LiveCred= New-Object System.Management.Automation.PsCredential($User,(ConvertTo-SecureString $Pass -AsPlainText -Force))
$AdminCenterURL  = "https://chgusa-admin.sharepoint.com" 
Connect-SPOService -url $AdminCenterURL -Credential $LiveCred
$LogFile = "C:\Users\cspiadmin\Desktop\OneDriveSites.txt"
Connect-SPOService -Url $AdminCenterURL
Get-SPOSite -IncludePersonalSite $true -Limit all -Filter "Url -like '-my.sharepoint.com/personal/'" | Select -ExpandProperty Url | Out-File $LogFile -Force
Write-Host "Done!"


#check Usage
$User = "chgservice@componenthardware.com"
$Pass = "Secure_1890"
$LiveCred= New-Object System.Management.Automation.PsCredential($User,(ConvertTo-SecureString $Pass -AsPlainText -Force))
$AdminCenterURL  = "https://chgusa-admin.sharepoint.com" 
Connect-SPOService -url $AdminCenterURL -Credential $LiveCred 
Import-Module Microsoft.Online.SharePoint.PowerShell
$adminURL = "https://chgusa-admin.sharepoint.com" 
Connect-SPOService -Url $adminURL
$URL = "https://chgusa-my.sharepoint.com/personal/rrao_chgonline_com"
Get-SPOSite -Identity $URL | select Owner, StorageUsageCurrent, StorageQuota, Status


#remove account
remove-SPOsite "https://chgusa-my.sharepoint.com/personal/tuser_componenthardware_com"

#verify archiving
Get-Mailbox -Identity username@componenthardware.com | Format-List Name,*Archive*

#verify retention policy
Get-Mailbox username | Select RetentionPolicy

Get-User WJones@componenthardware.com | select -ExpandProperty DistinguishedName
Get-Recipient -Filter "Members -eq 'CN=WJones,OU=chgusa.onmicrosoft.com,OU=Microsoft Exchange Hosted Organizations,DC=NAMPR04A008,DC=PROD,DC=OUTLOOK,DC=COM'"