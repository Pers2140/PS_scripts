#Enter New User Information First and Last Names
$Newname = Read-Host -Prompt 'type the name of the user '
$newfirst,$newlast = $newname.split(" ");
$newaduser = $newfirst[0]+$newlast;

#compose the password
Function Get-RandomAlphanumericString {
	
	[CmdletBinding()]
	Param (
        [int] $length = 8
	)

	Begin{
	}

	Process{
        Write-Output ( -join ((0x30..0x39) + ( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count $length  | % {[char]$_}) )
	}	
}

$pass = (Get-RandomAlphanumericString | Tee-Object -variable teeTime )
write-host User Password is: $pass



#Create the User in AD
$newuser = New-ADUser `
-Name $newaduser `
-GivenName $newfirst  `
-Surname $newlast `
-DisplayName $Newname `
-UserPrincipalName $newaduser@ceramictechnics.com `
-AccountPassword (Read-Host -AsSecureString "Input User Password") `
-Enabled $True;


#Enter the User to be copied information First and Last Name
$oldname = Read-Host -Prompt 'type the name of the user to copy';
$oldfirst,$oldlast = $oldname.split(" ");
$olduser = $oldfirst[0]+$oldlast


#Copy the information from the old user to copy into the new user 
$user = Get-ADUser -Filter "GivenName -eq '$oldfirst' -and Surname -eq '$oldlast'" -Properties * ;
$Company = $user.Company;
$title = $user.Title;
$off = $user.Office;
$tel = $user.telephoneNumber;
$dept = $user.Department;
$co = $user.country;
$st = $user.state;
$man = $user.Manager
Set-ADUser $newaduser -Company $Company;  
Set-ADUser $newaduser -Office $off;
Set-ADUser $newaduser -State $st;
Set-ADUser $newaduser -Country $co ;
Set-ADUser $newaduser -Manager $man; 
Set-ADUser $newaduser -Title $title ;
Set-ADUser $newaduser -telephoneNumber $tel;
Set-ADUser $newaduser -Department $dept;
Set-ADUser $newaduser -Description $newaduser;
set-aduser $newaduser -city $city;
Set-ADUser $newaduser -StreetAddress $address;
Set-ADUser $newaduser -State $state;
Set-ADUser $newaduser -EmailAddress $newaduser'@ceramictechnics.com';

#copy groups
Get-ADUser -Identity $olduser -Properties memberof | Select-Object -ExpandProperty memberof |  Add-ADGroupMember -Members $newaduser

#move the new user into the correct OU
$targetDN = get-aduser -identity $olduser | Select-Object -ExpandProperty DistinguishedName
get-aduser $newaduser | Move-ADObject -TargetPath $TARGETDN.substring($targetDN.IndexOf("OU="))


#Rename the User
Set-ADUser $newaduser -PassThru | Rename-ADObject -NewName $Newname;


$email = get-aduser $newaduser | select-object -ExpandProperty userprincipalname

#create user mailbox in 365
$User = "cspiadmin@ceramictechnics.com"
$Pass = "Bl0wingR0ck21"
$LiveCred = New-Object System.Management.Automation.PsCredential($User,(ConvertTo-SecureString $Pass -AsPlainText -Force))
$Cred = Get-Credential $LiveCred
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $Cred -Authentication Basic -AllowRedirection
Import-PSSession $Session

write-host "creating email address"
write-host User Password is: $pass;

New-Mailbox -Alias $newaduser `
-Name $newfirst `
-FirstName $newfirst `
-LastName $newlast `
-DisplayName "$Newname" `
-MicrosoftOnlineServicesID $newaduser@ceramictechnics.com `
-Password (Read-Host -AsSecureString "Input User Password") `
-ResetPasswordOnNextLogon $False;


#Enable Archiving
Enable-Mailbox -Identity $newaduser –Archive

Remove-PSSession $Session