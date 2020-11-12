##VM Power States

##Replace DRIVE_LOCATION with your drive path e.g. C:\Powershell
$VMfile="DRIVE_LOCATION\Azure-VMs.csv"
 
##Only Target Enabled Subscriptions
    $subs = Get-AzSubscription  | Where-Object -Property State -eq 'Enabled'

#Test
$vmobjs = @()

foreach ($sub in $subs)
{
    
    Write-Host Processing subscription $sub.SubscriptionName

    try
    {

        Select-AzSubscription -SubscriptionId $sub.SubscriptionId -ErrorAction Continue

        $vms = Get-AzVM 
       

        foreach ($vm in $vms)
        {
            $vmInfo = [pscustomobject]@{
                'Subscription'=$sub.Name
                'Location' = $vm.Location
                'ResourceGroupName' = $vm.ResourceGroupName
                'Name'=$vm.Name
                'ComputerName' = $vm.OSProfile.ComputerName
                'VMSize' = $vm.HardwareProfile.VMsize
                'DiskCount' = $vm.StorageProfile.DataDisks.Count
                'Admin' = $vm.OSProfile.AdminUsername
                'Status' = $null
                'IPAddress' = $null
                'ProvisioningState' = $vm.ProvisioningState
                'Publisher' = $vm.StorageProfile.ImageReference.Publisher
                'Offer' = $vm.StorageProfile.ImageReference.Offer
                'SKU' = $vm.StorageProfile.ImageReference.Sku
                'Version' = $vm.StorageProfile.ImageReference.Version  
                
                 }
        
            $vmStatus = $vm | Get-AzVM -Status
            $vmInfo.Status = $vmStatus.Statuses[1].DisplayStatus

            $nic = Get-AzPublicIpAddress -ResourceGroupName $vm.ResourceGroupName
            $vmInfo.IPAddress =  $nic.IpAddress


            $vmobjs += $vmInfo
            Write-Host $vmInfo.Subscription $vmInfo.Name
        }  
    }
    catch
    {
        Write-Host $error[0]
    }
}

$vmobjs | Export-Csv -NoTypeInformation -Path $VMfile
Write-Host "VM list written to $VMfile"