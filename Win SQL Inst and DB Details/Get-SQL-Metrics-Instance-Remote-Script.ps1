

$instances = (Get-Service | Where {$_.Status -eq "Running"} | ?{$_.Name -like "*mssql*"}) | % {$_.DisplayName.Split("(").TrimEnd(")")[1]} | select -Unique

$instanceArray = @()
$length = $($env:computername).length
##It is helpful to differentiate servers within a cluster. Recommend a number on the end, update substring settings to provide best cluster node definer 
$servernum = $($env:computername).substring($length -1,1)
##Similar to servernum, select string definer for environment e.g. Prod, QA, Build etc. Default returns 1 character (e.g. P,Q,B) 
$Enviro = $($env:computername).substring($length -2,1)


foreach ($instance in $instances) { 
try {
##This IF Statement will allow to query default instance and/or named instances depending on set up
    if ($instance -eq "MSSQLSERVER"){
    $server = "$($env:computername)"
    }
    else
    {
    $server = "$($env:computername)\$instance"
    }

    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
    $s = New-Object 'Microsoft.SqlServer.Management.Smo.Server' "$server"
##This will take a portion of the server name to differentiate it from others when exporting
##Update Substring value 0 to starting position in server name string, and Length value 3 to number of characters (recommend keeping it small)
    $ServerABC = $server.Substring(0,[Math]::Min($server.Length,3))
##This will take a portion of the SQL instance name to differentiate it from others when exporting
##Update Substring value 0 to starting position in server name string, and Length value 3 to number of characters (recommend keeping it small)
    $InstanceABC = $Instance.Substring(0,[Math]::Min($Instance.Length,3))
##One performance metric in SQL which is hard to obtain, can only be queried via T-SQL
    $Adhoc = Invoke-Sqlcmd -Query "SELECT Value FROM sys.configurations WHERE NAME = 'optimize for ad hoc workloads'" -ServerInstance $server

    $tableinsert = [pscustomobject]@{
            "$ServerABC-$Instance-I$($Enviro)$($servernum)--Server" = "$server"
            #"$ServerABC-$InstanceABC-I$($servernum)--RowKey" = (Get-Date -Format "ddMMyyyymmssfff")
            "$ServerABC-$Instance-I$($Enviro)$($servernum)--Collation"  = $($s.Collation)
            "$ServerABC-$Instance-I$($Enviro)$($servernum)--Defaultpath" = $($s.DefaultFile)
            "$ServerABC-$Instance-I$($Enviro)$($servernum)--Defaultlog" = $($s.DefaultLog)
            "$ServerABC-$Instance-I$($Enviro)$($servernum)--SQLSvcAcc" = $($s.ServiceAccount)
            "$ServerABC-$Instance-I$($Enviro)$($servernum)--Costthres" = $($s.Configuration.CostThresholdForParallelism.RunValue)
            "$ServerABC-$Instance-I$($Enviro)$($servernum)--Maxdop" = $($s.Configuration.MaxDegreeOfParallelism.RunValue)
            "$ServerABC-$Instance-I$($Enviro)$($servernum)--RAMmb" = $($s.PhysicalMemory)
            "$ServerABC-$Instance-I$($Enviro)$($servernum)--RAMuseKB" = $($s.PhysicalMemoryUsageInKB)
            #"$ServerABC-$Instance-I$($Enviro)$($servernum)--Logins" = $($s.Logins)
            "$ServerABC-$Instance-I$($Enviro)$($servernum)--OptAdHoc" = $AdHoc.ItemArray[0]
            }
            $instanceArray += $tableinsert
         }
              catch
    {
        $instanceArray += $error[0]
    } 
         }   
     $instanceArray | Out-Host