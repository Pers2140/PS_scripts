#Enter New User Information First and Last Names
$newName= Read-Host -Prompt 'type the name of the user ex. james carter '
$firstname,$lastname = $newName.split(" ");
$aduser = $firstname[0]+$lastname;
$aduserobj = ( Get-aduser -identity $aduser )

write-host "`n"$aduserobj.name"will be Separated! `n "  -ForegroundColor Red 
$outputUser = read-host -Prompt "`n ... continue? 1 for yes `n"

if ( $outputUser = '1' ){

    write-host "`n Proceeding with separation ... `n"
    #Disconnect-AzAccount
    #Disconnect-ExchangeOnline
    #$Credential=Get-Credential
    #Connect-AzureAD
    
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
        Remove-ADGroupMember -Identity $Group -Members $ADUser -Confirm:$false
    }
    write-host "`n Removed all security groups except Domain users ...`n"

    # Hide account from address list
    Set-ADUser -Identity $aduser -replace @{msExchHideFromAddressLists=$true}
    write-host "`n Hid account from address list ...`n"

    # Move AD object to OU “TERM Converted to Shared Mailbox”
    Move-ADObject -Identity $aduserobj.ObjectGUID -TargetPath 'OU="TERM Converted to Shared Mailbox",OU="Termination prep and on leave",DC=MNA,DC=local'
    write-host "`n Move AD object to | OU TERM Converted to Shared Mailbox | ...`n"
    
    # Check if emails will need to be forwarded
    $forward_email = read-host "Will emails need to be forwarded? If so where? If not hit ENTER"

    if ( $forward_email.Length -gt 1 ) {
        write-host "forwarded to $($forward_email)"
        #Connect to exchange to convert mailbox and hide from GAL or forward to email 
        Connect-ExchangeOnline
        Set-Mailbox -Identity $aduserobj.DisplayName -Type Shared 
        Set-Mailbox -Identity $aduserobj.DisplayName -ForwardingAddress $forward_email
        Set-Mailbox $aduserobj.UserPrincipalName -HiddenFromAddressListsEnabled $true
        write-host "`n Changed User's mailbox to shared and forwarded to $($forward_email)`n "

    }else{
        write-host "not forwarding"
        # Connect to exchange to convert mailbox and hide from GAL or forward to email 
        Connect-ExchangeOnline
        Set-Mailbox -Identity $aduserobj.DisplayName -Type Shared 
        Set-Mailbox $aduserobj.UserPrincipalName -HiddenFromAddressListsEnabled $true
        write-host "`n Changed User's mailbox to shared`n"

    }

    # Connect-ExchangeOnline
    # Connect to exchange to convert mailbox
    # Set-Mailbox $aduserobj.userprincipalname -type Shared
    # write-host "`n Changed User's mailbox to shared`n"

    # Remove O365 licenses
    $userUPN = $aduserobj.userprincipalname
    # Disable user
    Set-AzureADUser -ObjectID $userUPN -AccountEnabled $false
    write-host "`n Disabled user in Office 365 n"

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

    write-host "`n Remove licenses and disable account manually `n"
    write-host "`n Remove user from Sharefile => https://montenido.sharefile.com/ `n"

}Else{

    write-host "Not a valid answer"
}
