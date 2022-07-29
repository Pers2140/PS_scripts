$printer_ips = 
10.106.31.18,     
10.106.31.11,     
10.106.31.17,     
10.106.31.16,     
10.106.31.12,     
10.106.31.15,     
10.106.31.21,
10.106.31.19,
10.106.31.14,
10.106.31.10,
10.106.31.20,
10.106.31.22,
10.106.31.25,
10.106.31.27,
10.106.31.2

$count = 1

foreach ($ip in $printer_ips){

    $name = 'ZDesigner_printer' + $count
    Add-PrinterPort -name $name  -PrinterhostAddress $ip
    Add-Printer -name $name   -DriverName "ZDesigner ZT410-203dpi ZPL" -PortName $name
    $global:count++

}