

function returnCPUPercent {
    
    Get-Process | Select-Object CPU,name
    
}

returnCPUPercent