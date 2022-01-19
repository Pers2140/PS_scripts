write-host "adjusting Onedrive to 100GB"
$User = "chgservice@componenthardware.com"
$Pass = "Secure_1890"
$LiveCred= New-Object System.Management.Automation.PsCredential($User,(ConvertTo-SecureString $Pass -AsPlainText -Force))
$AdminCenterURL  = "https://chgusa-admin.sharepoint.com" 
Connect-SPOService -url $AdminCenterURL -Credential $LiveCred 
$mysitehost = "https://chgusa-my.sharepoint.com/personal/"
$personalsite=$newaduser+"_componenthardware_com"
$OneDriveSite = $personalsite
$OneDriveStorageQuota = 102400 
$OneDriveStorageQuotaWarningLevel = $OneDriveStorageQuota - 5120
Set-SPOSite -Identity $OneDriveSite -StorageQuota $OneDriveStorageQuota -StorageQuotaWarningLevel $OneDriveStorageQuotaWarningLevel 
Write-Host "Done" 
