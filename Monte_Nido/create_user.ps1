
Import-Module ActiveDirectory

$nuser = 'y'

While ( $nuser -eq 'y' ){
#Connect-MsolService
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
$title = $oldAduserobj.title



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

$ans = read-host "`n What will be this user's main SMTP email choose number 1-4`n choices: `n 1.@montenidoaffiliates.com `n 2.@clementineprograms.com `n 3.@oliverpyattcenters.com `n 4.@montenido.com `n`n"
switch ($ans) {
    1 { $SMTPmail = "@montenidoaffiliates.com" }
    2{ $SMTPmail = "@clementineprograms.com" }
    3{ $SMTPmail = "@oliverpyattcenters.com" }
    4{ $SMTPmail = "@montenido.com" }
    5{ $SMTPmail = "@rosewoodranch.com" }

    default { "Please choose a number between 1 - 4"; break;}
}


set-aduser -identity $newAduserSAM -replace @{mail="$newAduserSAM$SMTPmail"}

## Set SMTP mail address
$addresses = '@montenidoaffiliates.com' , '@clementineprograms.com' , '@oliverpyattcenters.com' , '@montenido.com', '@rosewoodranch.com'
$proxyAddresses = @("SMTP:$newAduserSAM$SMTPmail")

if ( $SMTPmail -ne "@rosewoodranch.com" ){

    foreach ( $a in $addresses ){
    
        if ( $a -ne $SMTPmail ){
        
            $proxyAddresses = $proxyAddresses + "smtp:$newAduserSAM$a"
        }
    }
}

$proxyAddressesDimits
set-aduser -identity $newAduserSAM -Add @{ProxyAddresses=$proxyAddresses}

# Sync Files
   Start-ADSyncSyncCycle -PolicyType Delta
Start-Sleep 5 
Write-host "Giving time to Sync ..."
# Change user's password to Welcome11 and enable MFA

#(Get-MsolUser -UserPrincipalName JLigasan@montenidoaffiliates.com).StrongAuthenticationMethods
#Set-MsolUser -UserPrincipalName $newUserAttrib.UserPrincipalName -StrongAuthenticationMethods @()
#Set-MsolUserPassword -UserPrincipalName $newUserAttrib.UserPrincipalName -NewPassword "Welcome11"


# Reset password
# Set-ADAccountPassword -Identity $user -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$Pass" -Force)

<#
write-host "`n add Zoom licenses  `n"
write-host "`n add user to Sharefile => https://montenido.sharefile.com/ `n"
[system.Diagnostics.Process]::Start("chrome","https://montenido.sharefile.com/users/clients/browse")
[system.Diagnostics.Process]::Start("chrome","https://montenido.zoom.us/account/user#/")
#>

# setup remote desktop
$Server="mna-rds.mna.local"
$User="MNA\$newAduserSAM"
$Password='Welcome11'
$SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force

#cmdkey /generic:$Server /user:$User /pass:$SecurePassword
#mstsc /v:$Server /h:1080 /w:1920
write-host "`n `n `n"
Write-Host @" 
** For Sharefile **

Hello,

I just sent you an e-mail link to activate your MN&A Citrix Share File Account.

This online file share service contains all the MN&A Kipu & Clinical documentation plus training materials.

Enjoy!
"@
write-host "`n `n `n"
$output = "

Hi Please see $newAduser[0]'s information below
 
Welcome to Monte Nido & Affiliates! 
Below you will find instructions on how to access the core, day to day business applications. 

Name: $newAduser
Job Title: $title

Computer Login: $newAduserSAM
Temp Password: $Password

Email: $newAduserSAM$SMTPmail
Temp Password: $Password

KIPU 

The KIPU EMR is our electronic medical records system specifically designed for - and from within - facilities treating SUD, eating disorders and behavioral health. 
It is a cloud-based, end-to-end EMR platform. 
https://mna11311.kipuworks.com/users/sign_in


ADP Workforce now

ADP Workforce Now is our cloud-based platform for HR management and payroll management. 
Polices, paystubs, W2’'s and all related items can be found here
https://workforcenow.adp.com/ 

Outlook Web Access

BEFORE USAGE
Please read the attached Policies and procedures.  By logging into this system outside of our typical environment you are agreeing to the terms of the attached P&P’'s
 
ACCESS
To use OWA, please navigate to  https://outlook.office365.com/ to login and start using this service.
 
Username: $newAduserSAM@montenidoaffiliates.com
 
IMPORTANT ! Your user name must end in  @montenidoaffiliates.com
 
Password:  $Password
 
HOW TO
Please watch these QuickStart videos to get familiar with the system. 
Help Videos
 
  
ZOOM

The below link will direct you to a set of training videos for ZOOM. These are concise and to the point and very helpful.
https://support.zoom.us/hc/en-us/articles/206618765-Zoom-Video-Tutorials
 

DOXY

Launch the Doxy website link from a web browser:
Credentials were sent to your @montenidoaffiliates.com email address. 
https://mna.doxy.me/

How to use DOXY – As a client 
-	Launch the Doxy website link from a web browser 
-	Enter Doctor’s room name – Example: DrWelch
-	To 'Check-In':
o	Enter your name, click 'Check-In'
o	You are now in your provider''s waiting room.  Wait for your provider to start the call.
NOTE – It is best to allow 20-30 seconds after the session has started so that the video stream can stabilize.


Sharefile         

I just sent you an e-mail link to activate your MN&A Citrix Share File Account.
This online file share service contains all the MN&A Kipu & Clinical documentation plus training materials.
https://montenido.sharefile.com/


Relias         

Healthcare learning management system that helps administrators quickly evaluate clinical skills, ensure compliance, and create custom learning plans for their staff. 
Account is created and managed by HR upon hiring. 
https://login.reliaslearning.com


Monte Nido & Affiliates IT Helpdesk 

Monte Nido & Affiliates utilizes a Ticketing system to manage I.T. Support Requests. 
If you''re in need of I.T. assistance please use the following methods to open a ticket and a HelpDesk representative will be in touch with you soon after to assist.

To Open a Ticket via Email:
-	Email: helpdesk@montenido.com This will open up a ticket for tracking and priority purposes.
-	Subject Line: Reason for creating the ticket – Example: 'My password expired'
-	E-mail message: This is where you provide a detailed description of the problem or request, your location and contact information.
 
To Open or Escalate a Ticket via Phone:
-	Call Technical Support at 954-571-4699

"
write-host $output 
Set-Clipboard -Value $output

Write-Host @"

Hello Michelle,

I have created $newfirstname's account, here is the login information.

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
$chrome = Read-Host "Start chrome? y or n"
if ($chrome -eq 'y') {[system.Diagnostics.Process]::Start("chrome","https://admin.microsoft.com/?auth_upn=CSPICS%40waldenbehavioralcare.com&source=applauncher#/users")} else {'..guess not'}

$nuser = Read-Host "add another user? y or n"
clear
}
write-host "Thank you come again"