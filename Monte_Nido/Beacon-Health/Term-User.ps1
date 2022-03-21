#Connect-AzureAD
# Get user object
$username = (read-host "`n Enter user to be terminated ") 
$user_OBJ = (Get-AzureADUser -SearchString $username)
write-host "`n `n$($user_OBJ.UserPrincipalName) will be terminated `n `n" -BackgroundColor Yellow -ForegroundColor Red
pause

# Disable user
Set-AzureADUser -ObjectID $user_OBJ.UserPrincipalName -AccountEnabled $false

write-host "`n Disabled user in Office 365 n"
# Get user group memberships
$user_groupMemberships = (Get-AzureADUser -ObjectId $user_OBJ.ObjectId).ObjectID
$user_groupMemberships

# Loop throught groups and remove user except for "All User" group
foreach ( $group in $user_groupMemberships){

    if ( $group -ne '5c2e06f5-2516-425d-965b-979d7161b187'){
        
        #write-host 'Removing from group' (Get-AzureADGroup -ObjectId $group).DisplayName
        Remove-AzureADGroupMember -ObjectId $group -MemberId $user_OBJ.ObjectId
        

    }else{
        
        write-host "`n *** Skipping All Users group ***`n"
    
    }

}

# Update fields to Term to remove from Dynamic groups
Set-AzureADUser -ObjectId $user_OBJ.ObjectId -JobTitle "Term - $($user_OBJ.JobTitle)" -Department "Term - $($user_OBJ.Department)" -CompanyName "Term - $($user_OBJ.CompanyName)"


# Check if emails will need to be forwarded

$forward_email = read-host "Will emails need to be forwarded? If so where? If not hit ENTER"

if ( $forward_email.Length -gt 1 ) {
    write-host "forwarded to $($forward_email)"
     #Connect to exchange to convert mailbox and hide from GAL or forward to email 
     Connect-ExchangeOnline
     Set-Mailbox -Identity $user_OBJ.DisplayName -ForwardingAddress $forward_email
     Set-Mailbox $user_OBJ.UserPrincipalName -HiddenFromAddressListsEnabled $true
     write-host "`n Changed User's mailbox to shared and forwarded to $($forward_email)`n "

}else{
    write-host "not forwarding"
    # Connect to exchange to convert mailbox and hide from GAL or forward to email 
    Connect-ExchangeOnline
    Set-Mailbox -Identity $user_OBJ.DisplayName 
    Set-Mailbox $user_OBJ.UserPrincipalName -HiddenFromAddressListsEnabled $true
    write-host "`n Changed User's mailbox to shared`n"

}

# Go through licenses and remove
$userList = Get-AzureADUser -ObjectID $user_OBJ.UserPrincipalName

$Skus = $userList | Select -ExpandProperty AssignedLicenses | Select SkuID

if($userList.Count -ne 0) {

    if($Skus -is [array])

    {

        $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses

        for ($i=0; $i -lt $Skus.Count; $i++) {

            $Licenses.RemoveLicenses +=  (Get-AzureADSubscribedSku | Where-Object -Property SkuID -Value $Skus[$i].SkuId -EQ).SkuID   

        }

        Set-AzureADUserLicense -ObjectId $user_OBJ.UserPrincipalName -AssignedLicenses $licenses

    } else {

        $licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses

        $Licenses.RemoveLicenses =  (Get-AzureADSubscribedSku | Where-Object -Property SkuID -Value $Skus.SkuId -EQ).SkuID

        Set-AzureADUserLicense -ObjectId $user_OBJ.UserPrincipalName -AssignedLicenses $licenses

    }

}

Write-Host @"

Off-boarding have been completed for $username
**********************************
Reset password
Block Office 365 sign-in, this also initiates a one-time sign out.
Remove from any and all groups (to remove from dynamic groups add "Term - " to the start of the Job Title, Department, and Company name fields of the user) ex
Remove from teams channels
Convert email to shared mailbox.
Removed Office license
To remove from e-fax group : Email sent to Lingo team
Prime-view access : user removed from Primeview
Email forwarded to : $forward_email
Onedrive access provided to Cameo Mundt , Please access $username's One Drive and copy file to your account. link: https://beaconhc-my.sharepoint.com/personal/cmundt_washington-ltc_com
Kindly check and revert if need help with this.

To Remove PCC and DSSI account : Email sent to Maria and Andrew.
************************************


"@