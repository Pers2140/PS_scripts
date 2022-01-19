$VpnName = "Rope Partner AutoVPN"
$VpnServer = "vpn-usw2.ropepartner.com"
$VpnDns = @("10.1.0.4", "192.168.88.16")
$VpnDnsSuffix = "ropepartner.local"
Add-VpnConnection -Name $VpnName -ServerAddress $VpnServer -TunnelType "SSTP" -EncryptionLevel "Required" -AuthenticationMethod MsCHAPv2 -SplitTunneling -Force -RememberCredential -UseWinLogonCredential -dnssuffix $VpnDnsSuffix
Add-VpnConnectionTriggerDnsConfiguration -ConnectionName $VpnName -DnsSuffix $VpnDnsSuffix -DnsIPAddress $VpnDns
Add-VpnConnectionTriggerTrustedNetwork -ConnectionName $VpnName -DnsSuffix $VpnDnsSuffix
Set-VpnConnectionTriggerDnsConfiguration -ConnectionName $VpnName -DnsSuffixSearchList $VpnDnsSuffix
Add-VpnConnectionRoute -ConnectionName $VpnName -destinationprefix 10.1.0.0/24 -routemetric 25
Add-VpnConnectionRoute -ConnectionName $VpnName -destinationprefix 192.168.88.0/24 -routemetric 25

$namespaceName = "root\cimv2\mdm\dmmap"
$className = "MDM_VPNv2_01"
$instance = Get-CimInstance -Namespace $namespaceName -ClassName $className -Filter "InstanceID = 'Rope%20Partner%20AutoVPN'"
$instance.AlwaysOn = $true
$instance.remembercredentials = $true
$instance.trustednetworkdetection = $VpnDnsSuffix
$instance | Set-ciminstance