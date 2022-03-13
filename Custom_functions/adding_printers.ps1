$printer_ips = '192.168.137.51'

$count = 1

foreach ($ip in $printer_ips){
   
    $name = 'HR-HQ-HP Color LaserJet Pro MFP M479fdn'+$count
    Add-PrinterPort -name $name  -PrinterhostAddress $ip
    Add-Printer -name $name   -DriverName "HP Color LaserJet A3/11x17 PCL6 Class Driver" -PortName $name
    $global:count++
}