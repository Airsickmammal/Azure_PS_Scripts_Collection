     $arrayy = @()
     $SVCObjs2 = @()
    $run = Get-CimInstance -ClassName Win32_Service |
##Replace SVC_MASK with mask for your target Windows Service(s)
    Where-Object Name -match SVC_MASK |
    Format-Table -Property Name,StartName,StartMode,State -AutoSize | Out-String
    $arrayy += $run
    $arrayy

     $arrayy | Out-Host