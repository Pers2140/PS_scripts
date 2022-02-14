#Enter New User Information First and Last Names
$newName= Read-Host -Prompt 'type the name of the user ex. james carter '
$firstname,$lastname = $newName.split(" ");
$aduser = $firstname[0]+$lastname;
$aduserobj = ( Get-aduser -identity $aduser )

#Disconnect-AzAccount
#Disconnect-ExchangeOnline
#  get credentials
#$Credential=Get-Credential
#Connect-AzureAD
#Connect-ExchangeOnline  

# Disable user 
Disable-ADAccount -Identity $aduser
write-host "`n Finished disabling user ...`n"

# Move AD object to OU “TERM Converted to Shared Mailbox”
Move-ADObject -Identity $aduserobj.ObjectGUID -TargetPath 'OU="TERM Converted to Shared Mailbox",OU="Termination prep and on leave",DC=MNA,DC=local'
write-host "`n Move AD object to | OU TERM Converted to Shared Mailbox | ...`n"

# Connect to exchange to convert mailbox
Set-Mailbox $aduserobj.userprincipalname -type Shared

# Remove O365 licenses
$userUPN = $aduserobj.userprincipalname
# Disable user
Set-AzureADUser -ObjectID $userUPN -AccountEnabled $false

# Run through licenses and remove
$userList = Get-AzureADUser -ObjectID $userUPN
$Skus = $userList | Select -ExpandProperty AssignedLicenses | Select SkuID
if($userList.Count -ne 0) {
    if($Skus -is [array])
    {
        $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        for ($i=0; $i -lt $Skus.Count; $i++) {
            $Licenses.RemoveLicenses +=  (Get-AzureADSubscribedSku | Where-Object -Property SkuID -Value $Skus[$i].SkuId -EQ).SkuID   
        }
        Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $licenses
    } else {
        $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        $Licenses.RemoveLicenses =  (Get-AzureADSubscribedSku | Where-Object -Property SkuID -Value $Skus.SkuId -EQ).SkuID
        Set-AzureADUserLicense -ObjectId $userUPN -AssignedLicenses $licenses
    }
}

