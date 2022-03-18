$splash = Get-WmiObject -Class Win32_Product | Where-Object {$_.name -eq "Splashtop Streamer"}
$splash.uninstall()