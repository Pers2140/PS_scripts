
Import-Module ActiveDirectory

<# Grab all needed information from template user#>
#-----------------------------------------------------------------

# Get old user to copy
$oldAduser = Read-Host "Please enter old first and last name "
$oldFirstname,$oldLastname = $oldAduser.split(" ");
$oldAduserSAM = $oldFirstname[0]+$oldLastname;
$oldAduserobj = ( Get-aduser -identity $oldAduserSAM -properties *)

# Get new user information
$newAduser = Read-Host "Please enter new user "
$newfirstname,$newlastname = $newAduser.split(" ");
$newAduserSAM = $newfirstname[0]+$newlastname;



# Setting template UPN property to null
# $newUserAttrib.UserPrincipalName = $null
# Splat all copied variables into one using template user properties
# $newUserAttrib = Get-ADUser -Identity $usertoCopy -Properties StreetAddress, City, Title, PostalCode, Office, Department, Manager
$newUserAttrib = @{
    Enable = $true
    ChangePasswordAtLogon = $true
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
set-aduser -identity $newAduserSAM  -add @{mailNickname=$newAduserSAM}

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
set-aduser -identity $newAduserSAM -replace @{mail="$newAduserSAM$SMTPmail"}

## Set SMTP mail address
$addresses = '@montenidoaffiliates.com' , '@clementineprograms.com' , '@oliverpyattcenters.com' , '@montenido.com'
$proxyAddresses = @("SMTP:$newAduserSAM$SMTPmail")

foreach ( $a in $addresses ){
    
    if ( $a -ne $SMTPmail ){
        
        $proxyAddresses = $proxyAddresses + "smtp:$newAduserSAM$a"
    }
}

$proxyAddressesDimits
set-aduser -identity $newAduserSAM -Add @{ProxyAddresses=$proxyAddresses}

# Sync Files
Start-ADSyncSyncCycle -PolicyType Delta


# Reset password
# Set-ADAccountPassword -Identity $user -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$Pass" -Force)

write-host "`n add Zoom licenses  `n"
write-host "`n add user to Sharefile => https://montenido.sharefile.com/ `n"
[system.Diagnostics.Process]::Start("chrome","https://montenido.sharefile.com/users/clients/browse")
[system.Diagnostics.Process]::Start("chrome","https://montenido.zoom.us/account/user#/")

# setup remote desktop
$Server="mna-rds.mna.local"
$User="MNA\$newAduserSAM"
$Password="Welcome11"
$SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force

cmdkey /generic:$Server /user:$User /pass:$SecurePassword
mstsc /v:$Server /h:1080 /w:1920
write-host "`n `n `n"
Write-Host @" 
** For Sharefile **

Hello,

I just sent you an e-mail link to activate your MN&A Citrix Share File Account.

This online file share service contains all the MN&A Kipu & Clinical documentation plus training materials.

Enjoy!
"@
write-host "`n `n `n"
Write-Host @"

Hello Michelle,

I have created $newfirstname  account, here is the login information.

Username:$newAduserSAM
Email: $newAduserSAM$SMTPmail
Password: $Password

I have created the Zoom and Sharefile accounts and sent to users email.

Adding internal IT for additional access.

Thank you,
"@
write-host "`n `n `n"
Write-Host @"

Make sure the following apps are selected: 

- Azure Rights Management

- Common Data Service

- Exchange Online (Plan 2)

- Information Protection for Office 365 - Standard

- Microsoft 365 Apps for enterprise

* Disable OWA for Oulook Apps
Monte Nido & Affiliates
"@
