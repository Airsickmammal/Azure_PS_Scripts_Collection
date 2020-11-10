Function Get-AZVMCreated { 
<# 
  .SYNOPSIS 
  Function "Get-AZVMCreated" will connect to a given tenant and parse through the subscriptions and output Azure VM details based on creation date. 
 
  .DESCRIPTION 
  Author: Pwd9000
  Updated: Airsickmammal
 
  The user must specify the TenantId when using this function. 
  The function will request access credentials and connect to the given Tenant. 
  Granted the identity used has the required access permisson the function will parse through all subscriptions  
  and gather data on Azure Vms based on the creation date. 
#> 
 
[CmdletBinding()] 
param( 
    [Parameter(Mandatory = $True, 
        ValueFromPipeline = $True)] 
    [string]$TenantId 
)  
Connect-AzureAD
 
#------------------------------------------------Obtain Credentials for Session------------------------------------------------------------ 
$Credential = Get-Credential 
 
#---------------------------------------------Get all Subscription Ids for given Tenant---------------------------------------------------- 
##Replace SUBSCRIPTION_MASK with mask for your subscriptions, if needed. If not needed, remove Where-Object section. Note you can also use -ne for "not like"
$SubscriptionIds = (Get-AzSubscription -TenantId $TenantId| Where-Object -Property State -eq 'Enabled' | Where-Object -Property Name -like "*SUBSCRIPTION_MASK").Id 
 
#-------------------------------------------------Create Empty Table to capture data------------------------------------------------------- 
$Table = @() 

Foreach ($Subscription in $SubscriptionIds) { 
    Write-Host "Checking Subscription: $Subscription. for any Azure VMs and their creation date. This process may take a while. Please wait..." -ForegroundColor Green 
 
    $RMAccount = Add-AzAccount -Credential $Credential -TenantId $TenantId -Subscription $subscription 
    Get-AzDisk | Where-Object {$_.TimeCreated -le (Get-Date)} | 
            Select-Object Name, ManagedBy, Resourcegroupname, TimeCreated | 
            ForEach-Object { 
                Try { 
                    $ErrName = $_.Name 
                    $AzDiskManagedBy = $_.managedby | Split-path -leaf 
                    $AzDiskManagedByRG = $_.ResourceGroupName 
                    $CreationDate = $_.TimeCreated 
                    $OS = (Get-AzVM -name $AzDiskManagedBy -ResourceGroup $AzDiskManagedByRG).StorageProfile.ImageReference.Offer 
                    $SKU = (Get-AzVM -name $AzDiskManagedBy -ResourceGroup $AzDiskManagedByRG).StorageProfile.ImageReference.SKU 
                    $Table += [pscustomobject]@{VMName = $AzDiskManagedBy; Created = $CreationDate; ResourceGroup = $AzDiskManagedByRG; OperatingSystem = $OS; SKU = $SKU} 
                } 
                Catch { 
                    Write-Host "Cannot determine machine name associated with disk: [$ErrName]. Skipping drive-check for this item..." -ForegroundColor Yellow 
                    Write-Host "Continue Checking Subscription: $Subscription. for any Azure VMs and their creation date. This process may take a while. Please wait..." -ForegroundColor Green 
                } 
            } 
} 
$UniqueVMs = $Table | Sort -Unique -Property VMName 
$UniqueVMs 
Write-Host "" -ForegroundColor Green 
Write-Host "Number of disks associated with VMs: $($Table.Count)" -ForegroundColor Green 
Write-Host "Number of disks unable to associate with VMs: $($ErrName.Count)" -ForegroundColor Yellow 
Write-Host "Number of unique Azure VMs associated with disks: $($UniqueVMs.Count)" -ForegroundColor Green 
Write-Host "Script finished.." -ForegroundColor Green 
} 
 
<#---- Transform Commands - Get-AZVMCreated Function calls To Break Down Results by OS Type or export all----- 

##Replace TENANT_ID with Azure Tenant ID 
$TenantId = "TENANT_ID" 

#-------------------BUILD ---------------------- 
##RUN THIS to populate $AZVMsAll
$AZVMsAll = Get-AZVMCreated -TenantId $TenantId | sort-object -property Created 
 
#-------------------REFINE----------------------
##If you want to break down by specific OS type, run apropriate line-only
$Win10 = $AZVMsAll | Where-Object {$_.SKU -like "*Windows-10*"} | sort-object -property Created 
$Win8 = $AZVMsAll | Where-Object {$_.SKU -like "*Win81*"} | sort-object -property Created 
$Win7 = $AZVMsAll | Where-Object {$_.SKU -like "*Win7*"} | sort-object -property Created 
$Server2008R2 = $AZVMsAll | Where-Object {$_.SKU -like "*2008-R2*"} | sort-object -property Created 
$Server2012R2 = $AZVMsAll | Where-Object {$_.SKU -like "*2012-R2*"} | sort-object -property Created 
$Server2016 = $AZVMsAll | Where-Object {$_.SKU -like "*2016*"} | sort-object -property Created 
$RHEL = $AZVMsAll | Where-Object {$_.OperatingSystem -like "*RHEL*"} | sort-object -property Created 
$Ubuntu = $AZVMsAll | Where-Object {$_.OperatingSystem -like "*Ubuntu*"} | sort-object -property Created 
$Centos = $AZVMsAll | Where-Object {$_.OperatingSystem -like "*Centos*"} | sort-object -property Created 

#-------------------CHECK----------------------- 
##Check the results before exporting
##Run this to display all VMs In results
$AZVMsAll 
#-------------------EXPORT-----------------------
##Run the following lines to export results
$myTable = @()
$myTable += $AZVMsAll | Select-Object -Property VMName,Created

##Replace DRIVE_LOCATION with your drive path e.g. C:\Powershell
$myTable | Export-Csv -NoTypeInformation -Path "DRIVE_LOCATION\Azure-VM-Created.csv"
-----------------------------------------------------------------------------------------------#> 
 
 

