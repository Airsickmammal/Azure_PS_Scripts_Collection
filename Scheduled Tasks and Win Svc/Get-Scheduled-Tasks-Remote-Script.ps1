$SCHObjs = @()

##Replace SERVICE_MASK with mask for your Scheduled Task(s)
$GetSch =  Get-ScheduledTask -TaskName *SERVICE_MASK*

foreach ($GetSch in $GetSch)
{
$SCHInfo = [pscustomobject]@{
        'Server' = $env:computername.ToUpper()
        'TaskName' = $GetSch.TaskName
        }
        $Schobjs += $SCHInfo
        }
$SCHobjs | Format-Table -HideTableHeaders | Out-Host