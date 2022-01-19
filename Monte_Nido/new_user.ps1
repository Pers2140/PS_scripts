#Enter New User Information First and Last Names
$Newname = Read-Host -Prompt 'type the name of the user '
$newfirst,$newlast = $newname.split(" ");
$newaduser = $newfirst[0]+$newlast;


#Create the User in AD
$newuser = New-ADUser `
-Name $newaduser `
-GivenName $newfirst  `
-Surname $newlast `
-DisplayName $Newname `
-UserPrincipalName $newaduser@ceramictechnics.com `
-AccountPassword (Read-Host -AsSecureString "Input User Password") `
-Enabled $True;