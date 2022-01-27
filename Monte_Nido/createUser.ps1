
Import-Module ActiveDirectory

<# Grab all needed information from template user#>
#-----------------------------------------------------------------

# Get old user to copy
$oldAduser = Read-Host "Please enter old first and last name "
$oldFirstname,$oldLastname = $oldAduser.split(" ");
$oldAduserSAM = $oldFirstname[0]+$oldLastname;
$oldAduserobj = ( Get-aduser -identity $oldAduserSAM -properties *)

# Get new user information
$newAduser = Read-Host -Prompt 'type the name of the new user '
$newfirstname,$newlastname = $newAduser.split(" ");
$newAduserSAM = $newfirstname[0]+$newlastname;



# Setting template UPN property to null
# $newUserAttrib.UserPrincipalName = $null
# Splat all copied variables into one using template user properties
# $newUserAttrib = Get-ADUser -Identity $usertoCopy -Properties StreetAddress, City, Title, PostalCode, Office, Department, Manager
$newUserAttrib = @{
    Enable = $true
    # ChangePasswordAtLogon = $true
    Name = "$($newFirstname) $($newLastname)"
    GivenName = $newFirstname
    Surname = $newLastname
    DisplayName = "$($newFirstname) $($newLastname)"
    UserPrincipalName = $newAduserSAM+'@'+$oldAduserobj.userprincipalname.split('@')[1]
    sAMAccountName = $newAduserSAM
    Description = $oldAduserobj.Description
    Office = $oldAduserobj.office
    Company = $oldAduserobj.Company
    Department = $oldAduserobj.Department
    Title = $oldAduserobj.title
    City = $oldAduserobj.City
    State = $oldAduserobj.State

    AccountPassword = "Welcome11" | ConvertTo-SecureString -AsPlainText -Force

}


$targetDN = get-aduser -identity $oldAduserSAM | Select-Object -ExpandProperty DistinguishedName
New-ADUser @newUserAttrib -Path $TARGETDN.substring($targetDN.IndexOf("OU="))

# Added new user to previous user groups
foreach ( $group in (Get-ADUser $oldAduserSAM -Properties MemberOf).Memberof){
    Add-ADGroupMember -Identity $group -Members $newAduserSAM
}

# Set manager 
$manager = Get-ADUser $oldAduserSAM -Properties Manager | Select -ExpandProperty Manager
Set-ADUser -Identity $newAduserSAM -Manager $manager
# Attribute adjustments

# change mail nickname
set-aduser -identity brink -replace @{mailNickname=$newAduserSAM}

# change mail attribute
Write-Host @"


*******************************************************************
- EUser @ one of the four depending on location as shown in Site Acronym Document and at bottom of this guide

EUser@montenidoaffiliates.com Remote Staff and staff working at MNA
EUser@oliverpyattcenters.com Oliver Pyatt Centers
EUser@clementineprograms.com Clementine Programs
EUser@Montenido.com Monte Nido and Eating Disorder Center of xyz
*******************************************************************


"@

$SMTPmail = read-host "`n What will be this user's main SMTP email `n choices: `n @montenidoaffiliates.com `n @clementineprograms.com `n @oliverpyattcenters.com `n @montenido.com `n`n"
set-aduser -identity $newAduserSAM -replace @{mail=$newAduserSAM+$SMTPmail}

## Set SMTP mail address
$addresses = '@montenidoaffiliates.com' , '@clementineprograms.com' , '@oliverpyattcenters.com' , '@montenido.com'
$proxyAddresses = @("SMTP:$newAduserSAM+$SMTPmail")

foreach ( $a in $addresses ){
    
    if ( $a -ne $SMTPmail ){
        
        $proxyAddresses = $proxyAddresses + "smtp:$newAduserSAM+$a"
    }
}

$proxyAddresses
set-aduser -identity $newAduserSAM -Add @{ProxyAddresses=$proxyAddresses}

cls

# Reset password
# Set-ADAccountPassword -Identity $user -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$Pass" -Force)

