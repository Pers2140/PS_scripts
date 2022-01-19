
Import-Module ActiveDirectory

<# Grab all needed information from template user#>
#-----------------------------------------------------------------

# Get old user to copy
$oldAduser = Read-Host "Please enter old first and last name "
$oldFirstname,$oldLastname = $oldAduser.split(" ");
$oldAduserSAM = $oldFirstname[0]+$oldLastname;
$aduserobj = ( Get-aduser -identity $oldAduserSAM )

# Get new user information
$newAduser = Read-Host -Prompt 'type the name of the new user '
$newfirstname,$newlastname = $newAduser.split(" ");
$newAduserSAM = $newfirstname[0]+$newlastname;


# Get domain and OU and UPN ( "@dplabs.com")
$DN = (Get-ADUser  $oldAduserSAM -Properties *).CanonicalName.Split("/")[0]
$OU = (Get-ADUser  $oldAduserSAM -Properties *).CanonicalName.Split("/")[1]
$UPN = ("@"+$DN)

# Setting template UPN property to null
$newUserAttrib.UserPrincipalName = $null
# Splat all copied variables into one using template user properties
# $newUserAttrib = Get-ADUser -Identity $usertoCopy -Properties StreetAddress, City, Title, PostalCode, Office, Department, Manager
$newUserAttrib = @{
    Enable = $true
    # ChangePasswordAtLogon = $true
    Name = "$($newFirstname) $($newLastname)"
    GivenName = $newFirstname
    Surname = $newLastname
    DisplayName = "$($newFirstname) $($newLastname)"
    UserPrincipalName = "$($newAduserSAM)@$($DN)"
    sAMAccountName = $newAduserSAM
    Description = ""
    Office = ""
    Company = ""
    Department = ""
    Title = ""
    City = ""
    State = ""

    AccountPassword = "Welcome11" | ConvertTo-SecureString -AsPlainText -Force

}
<# Grab all needed information from template user#>
#-----------------------------------------------------------------



# Create new user
# New-ADUser -Name "$($newFirstname) $($lname)" -GivenName $fname -Surname $lname -Instance $newUserAttrib -SamAccountName $formatname -UserPrincipalName $formatname$UPN -DisplayName "$($fname) $($lname)" -AccountPassword (ConvertTo-SecureString -AsPlainText "$newPass" -Force) -ChangePasswordAtLogon $true -Enabled $true
$location = read-host "Target path to place user"
New-ADUser @newUserAttrib -Path "$location"




# Added new user to previous user groups
foreach ( $group in (Get-ADUser $oldAduserSAM -Properties MemberOf).Memberof){
    Add-ADGroupMember -Identity $group -Members $newAduserSAM
}
cls

# Reset password
# Set-ADAccountPassword -Identity $user -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$Pass" -Force)

