$printer_ips = '192.168.137.51'

$count = 1

foreach (192.168.137.181 in $printer_ips){
   
    $global:count++
}

    ping 192.168.136.24
    $name = 'Accounting Brother New'
    Add-PrinterPort -name '192.168.137.181'  -PrinterhostAddress '192.168.137.181'
    Add-Printer -name $name   -DriverName "Brother MFC-9330CDW Printer" -PortName '192.168.137.181'