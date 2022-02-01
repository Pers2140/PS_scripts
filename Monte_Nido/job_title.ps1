#Enter New User Information First and Last Names
$newName= Read-Host -Prompt 'type the name of the user ex. james carter '
$firstSAAname,$lastname = $newName.split(" ");
$aduserSAM = $firstname[0]+$lastname;
$aduserobj = ( Get-aduser -identity $aduser )

# Search for correct extensionAttribute1 
$search = read-host -Prompt 'enter search term for job title'
Get-aduser -Properties extensionAttribute1 -Filter "extensionAttribute1 -like '*$search*'"
$ea1 = Read-Host -Prompt 'enter correct extensionAttribute1'

# Replace title and extensionAttribute1
set-aduser -Identity $aduserSAM -Replace @{description=$ea1;title=$ea1;extensionAttribute1=$ea1}

