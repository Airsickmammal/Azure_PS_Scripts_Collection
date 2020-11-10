##OMS Device List Gather

##Replace DRIVE_LOCATION with your drive path e.g. C:\Powershell
$OMSfile="DRIVE_LOCATION\Azure-OMS.csv"

$omsobjs = @()

foreach ($sub in $subs)
{
    
    Write-Host Processing subscription $sub.SubscriptionName

    try
    {

        Select-AzSubscription -SubscriptionId $sub.SubscriptionId -ErrorAction Continue
         
        $oms = Get-AzOperationalInsightsWorkspace 

        foreach ($oms in $oms)
        {
            $omsInfo = [pscustomobject]@{
                'Name'=$oms.Name
                'ResourceGroupName'=$oms.ResourceGroupName
                'CustomerId'=($oms.CustomerId).Guid
                'Location'=$oms.Location
        }       

            $omsobjs += $omsInfo
            Write-Host $omsInfo.Name $omsInfo.ResourceGroupName $omsInfo.CustomerId $omsInfo.Location
        }  
    }
    catch
    {
        Write-Host $error[0]
    }
}

$omsobjs | Export-Csv -NoTypeInformation -Path $OMSfile
Write-Host "OMS list written to $OMSfile"