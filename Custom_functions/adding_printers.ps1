$printer_ips = '192.168.136.202','192.168.136.255','192.168.137.188','192.168.136.104','192.168.137.123','192.168.136.44'

$count = 1

foreach ($ip in $printer_ips){
   
    $name = 'ZDesigner_printer'+$count
    Add-PrinterPort -name $name  -PrinterhostAddress $ip
    Add-Printer -name $name   -DriverName "ZDesigner ZT410-203dpi ZPL" -PortName $name
    $global:count++
}