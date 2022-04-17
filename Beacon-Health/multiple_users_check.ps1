Get-ADUser -Filter * -Properties UserPrincipalName | 
foreach {  if (($_.UserprincipalName.tostring().split("@")[1] -ne 'montenidoaffiliates.com') -and 
               ($_.UserprincipalName.tostring().split("@")[1] -ne 'rosewoodranch.com') -and 
               ($_.UserprincipalName.tostring().split("@")[1] -ne 'rosewoodranch.com') ) 
               
               {$_.UserprincipalName}} 

