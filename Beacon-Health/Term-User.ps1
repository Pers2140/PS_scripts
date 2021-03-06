# Connect-AzureAD
# Get user object
$username = (read-host "`n Enter user to be terminated ") 
$user_OBJ = (Get-AzureADUser -SearchString $username)
write-host "`n `n$($user_OBJ.UserPrincipalName) will be terminated `n `n" -BackgroundColor Yellow -ForegroundColor Red
pause

# Disable user
Set-AzureADUser -ObjectID $user_OBJ.UserPrincipalName -AccountEnabled $false


# Get user group memberships
$user_groupMemberships = (Get-AzureADUserMembership -ObjectId $user_OBJ.ObjectId) 


# Update fields to Term to remove from Dynamic groups
Set-AzureADUser -ObjectId $user_OBJ.ObjectId -JobTitle "Term - $($user_OBJ.JobTitle)" -Department "Term - $($user_OBJ.Department)" -CompanyName "Term - $($user_OBJ.CompanyName)"

# Loop throught groups and remove user except for "All User" group
foreach ( $group in $user_groupMemberships){

    if ( $group -ne '5c2e06f5-2516-425d-965b-979d7161b187'){
        
        #write-host 'Removing from group' (Get-AzureADGroup -ObjectId $group).DisplayName
        Remove-AzureADGroupMember -ObjectId $group.ObjectID -MemberId $user_OBJ.ObjectId
        

    }else{
        
        write-host "`n *** Skipping All Users group ***`n"
    
    }

}



# Check if emails will need to be forwarded

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

Hi Tammy,

$username account has been Offboarded and emails forwarded to $forward_email



*** Internal Notes ***

- Reset password
- Block Office 365 sign-in
- Remove from any and all groups except the "All Users" group
- Forwarded emails to $forward_email
- Convert email to shared mailbox
- Removed License
- Sent email to remove from Fax


"@