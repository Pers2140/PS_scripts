
Import-Module ActiveDirectory

<# Grab all needed information from template user#>
#-----------------------------------------------------------------

# Get user to copy
$usertoCopy = Read-Host "Please enter user to copy"

# Setting template UPN property to null
$newUserAttrib.UserPrincipalName = $null

# Get user's first and last name
$fname = Read-Host "Please enter the first name"
$lname = Read-Host "Please enter user's last name"
$fullname = $fname+$lname
$formatname = $fullname.Substring(0,1)+$lname

# Get domain and OU and UPN ( "@dplabs.com")
$DN = (Get-ADUser dpersaud -Properties *).CanonicalName.Split("/")[0]
$OU = (Get-ADUser dpersaud -Properties *).CanonicalName.Split("/")[1]
$UPN = ("@"+$DN)

# Splat all copied variables into one using template user properties
# $newUserAttrib = Get-ADUser -Identity $usertoCopy -Properties StreetAddress, City, Title, PostalCode, Office, Department, Manager
$newUserAttrib = @{
    Enable = $true
    ChangePasswordAtLogon = $true
    Name = "$($fname) $($lname)"
    GivenName = $fname
    Surname = $lname
    DisplayName = "$($fname) $($lname)"
    UserPrincipalName = "$($formatname)@$($DN)"
    sAMAccountName = $formatname
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


#test

# Create new user
# New-ADUser -Name "$($fname) $($lname)" -GivenName $fname -Surname $lname -Instance $newUserAttrib -SamAccountName $formatname -UserPrincipalName $formatname$UPN -DisplayName "$($fname) $($lname)" -AccountPassword (ConvertTo-SecureString -AsPlainText "$newPass" -Force) -ChangePasswordAtLogon $true -Enabled $true
New-ADUser @newUserAttrib -Path "OU=Warehouse,DC=dplab,DC=com"





# Showing usertocopy group names
Write-host "`n" $usertoCopy "belongs to: "
$usertoCopyGroups = (get-aduser $usertoCopy -Properties * | Select-Object Memberof).memberOf
Write-host $usertoCopyGroups

# Add to multiple groups
$continue = $true
while( $continue )
{
    
    $yorn = Read-Host "`n Do you need to add to group? Y or N"
    
    if ($yorn = "Y"){
        # Adding new user to correct groups
        $group = Read-Host "Please enter the group"
        Add-ADGroupMember -Identity $group -Members $formatname
    }
    else {
        Write-Host "We are done here ..."
        $yorn = $false
    }
}

# Reset password
# Set-ADAccountPassword -Identity $user -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$Pass" -Force)

