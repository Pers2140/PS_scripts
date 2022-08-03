
#Enter New User Information First and Last Names
$newName= Read-Host -Prompt 'type the name of the user ex. james carter '
$firstname,$lastname = $newName.split(" ");
$aduser = $firstname[0]+$lastname
$aduserobj = ( Get-aduser -identity $aduser )

write-host "`n"$aduserobj.name"will be Separated! `n "  -ForegroundColor Red 
$outputUser = read-host -Prompt "`n ... continue? 1 for yes `n"

if ( $outputUser = '1' ){

    write-host "`n Proceeding with separation ... `n"
    #Disconnect-AzAccount
    #Disconnect-ExchangeOnline
    #$Credential=Get-Credential
   
    
    # Disable user 
    Disable-ADAccount -Identity $aduser
    write-host "`n Finished disabling user ...`n"

    # State/Province contents deleted
    Set-ADUser -Identity $aduser -State ' '
    write-host "`n State/Province contents deleted ... `n"

    # Change title,Department,Company to 'Term'
    $termDate= Read-Host -Prompt 'copy and paste term date'
    Set-ADUser -Identity $aduser -Replace @{title="Term";department=$termDate;Company="Term"}
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

   
    }

    
    write-host "`n Remove user from 365 manually unable to connect to azure server using TLS version 1.0, 1.1 and/or 3DES cipher which are deprecated to improve the security posture of Azure AD`n"

