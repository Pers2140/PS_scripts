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




# Remove O365 licenses
$userUPN = $aduserobj.userprincipalname
# Disable user
Set-AzureADUser -ObjectID $userUPN -AccountEnabled $false

# Connect to exchange to convert mailbox
# Check if emails will need to be forwarded
#Set-Mailbox $aduserobj.userprincipalname -type Shared
$forward_email = read-host "Will emails need to be forwarded? If so where? If not hit ENTER"

if ( $forward_email.Length -gt 1 ) {
    write-host "forwarded to $($forward_email)"
     #Connect to exchange to convert mailbox and hide from GAL or forward to email 
     Connect-ExchangeOnline
     Set-Mailbox -Identity $user_OBJ.DisplayName -Type Shared 
     Set-Mailbox -Identity $user_OBJ.DisplayName -ForwardingAddress $forward_email
     Set-Mailbox $user_OBJ.UserPrincipalName -HiddenFromAddressListsEnabled $true
     write-host "`n Changed User's mailbox to shared and forwarded to $($forward_email)`n "

}else{
    write-host "not forwarding"
    # Connect to exchange to convert mailbox and hide from GAL or forward to email 
    Connect-ExchangeOnline
    Set-Mailbox -Identity $user_OBJ.DisplayName -Type Shared 
    Set-Mailbox $user_OBJ.UserPrincipalName -HiddenFromAddressListsEnabled $true
    write-host "`n Changed User's mailbox to shared`n"

}
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

