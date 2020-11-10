$instances = (Get-Service | Where {$_.Status -eq "Running"} | ?{$_.Name -like "*mssql*"}) | % {$_.DisplayName.Split("(").TrimEnd(")")[1]} | select -Unique

$instanceArray = @()
$length = $($env:computername).length
##It is helpful to differentiate servers within a cluster. Recommend a number on the end, update substring settings to provide best cluster node definer 
$servernum = $($env:computername).substring($length -1,1)
##Similar to servernum, select string definer for environment e.g. Prod, QA, Build etc. Default returns 1 character (e.g. P,Q,B) 
$Enviro = $($env:computername).substring($length -2,1)

foreach ($instance in $instances) { 
##This IF Statement will allow to query default instance and/or named instances depending on set up
try {
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
##Replace DB_MASK for any DB name masks you wish to omit. Instead of -ne you can also use -like, or remove the Where-Object section completely
 $Return = $s.databases.Where{$_.IsSystemObject -eq $false}| Select Name,Size,Collation,RecoveryModel,SpaceAvailable,SpaceUsed,AvailabilityDatabaseSynchronizationState,AvailabilityGroupName,CreateDate,DataSpaceUsage,IndexSpaceUsage,IsSystemObject,LastBackupDate,LastLogBackupDate,Owner,PrimaryFilePath,ReadOnly | Where-Object -Property Name -Notlike ('*DB_MASK*')
       foreach ($Return in $Return)

            { $tableinfo =  [pscustomobject]@{ 
                             "$ServerABC-$InstanceABC-D$($Enviro)$($servernum)-$($Return.Name)-DBSize"=$Return.Size
                             "$ServerABC-$InstanceABC-D$($Enviro)$($servernum)-$($Return.Name)-Coll"=$Return.Collation
                             "$ServerABC-$InstanceABC-D$($Enviro)$($servernum)-$($Return.Name)-Recov"=$Return.RecoveryModel
                             "$ServerABC-$InstanceABC-D$($Enviro)$($servernum)-$($Return.Name)-SpaceAv"=$Return.SpaceAvailable
                             "$ServerABC-$InstanceABC-D$($Enviro)$($servernum)-$($Return.Name)-AOSync" =$Return.AvailabilityDatabaseSynchronizationState
                             #"$ServerABC-$InstanceABC-D$($Enviro)$($servernum)-$($Return.Name)-AOG" =$Return.AvailabilityGroupName
                             #"$ServerABC-$InstanceABC-D$($Enviro)$($servernum)-$($Return.Name)-Created" =$Return.CreateDate
                             "$ServerABC-$InstanceABC-D$($Enviro)$($servernum)-$($Return.Name)-Size" =$Return.DataSpaceUsage
                             "$ServerABC-$InstanceABC-D$($Enviro)$($servernum)-$($Return.Name)-IndexSize" =$Return.IndexSpaceUsage
                             "$ServerABC-$InstanceABC-D$($Enviro)$($servernum)-$($Return.Name)-SYSObj" =$Return.IsSystemObject
                             "$ServerABC-$InstanceABC-D$($Enviro)$($servernum)-$($Return.Name)-LstBkup" =$Return.LastBackupDate
                             "$ServerABC-$InstanceABC-D$($Enviro)$($servernum)-$($Return.Name)-LstLogBkup" =$Return.LastLogBackupDate
                             "$ServerABC-$InstanceABC-D$($Enviro)$($servernum)-$($Return.Name)-Own" =$Return.Owner
                             "$ServerABC-$InstanceABC-D$($Enviro)$($servernum)-$($Return.Name)-FilePath" =$Return.PrimaryFilePath
                             #"$ServerABC-$InstanceABC-D$($Enviro)$($servernum)-$($Return.Name)-ReadOnly" =$Return.ReadOnly
                              }
                              $instanceArray += $tableinfo  
         }
     } 
     catch
    {
     $instanceArray += $error[0]
    } 
     }

     $instanceArray | Out-Host
