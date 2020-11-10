##SQL Metrics Gather
Connect-AzureAD

##Replace DRIVE_LOCATION with your drive path e.g. C:\Powershell
$FileName = "DRIVE_LOCATION\SQLMetrics.csv"
$FileName

##Replace SUBSCRIPTION_MASK with mask for your subscriptions, if needed. If not needed, remove Where-Object section. Note you can also use -ne for "not like"
 $subs = Get-AzSubscription | Where-Object -Property State -eq 'Enabled' | Where-Object -Property Name -like ('*SUBSCRIPTION_MASK') |  Select-Object -Property Name | Sort-Object

  $SQLArray = @()
  $SQLArray2 = @()

##Replace DRIVE_LOCATION with your drive path e.g. C:\Powershell, however Get-SQL-Metrics-Instance-Remote-Script.ps1 must be in that location
  $SPath = "DRIVE_LOCATION\Get-SQL-Metrics-Instance-Remote-Script.ps1"
##Replace DRIVE_LOCATION with your drive path e.g. C:\Powershell, however Get-SQL-Metrics-DB-Remote-Script.ps1 must be in that location
  $SPath2 = "DRIVE_LOCATION\Get-SQL-Metrics-DB-Remote-Script.ps1"

foreach ($subs in $subs)
{
Write-Host $subs.Name
Select-AzSubscription -SubscriptionName $subs.Name | Out-null

 $ResGroup = (Get-azResourceGroup).ResourceGroupName
	foreach ($ResGroup in $ResGroup){
	
$vm = Get-azVM -ResourceGroupName $ResGroup

##Replace SQL_VM_MASK with VM Mask you wish to use. It would be safest to separate your Test and Production Queries due to the query scope, at least for test run.
$VMNameParam = "SQL_VM_MASK"
		   		
foreach ($vm in $vm) {                     

 if ($vm.Name -match $VMNameParam) {  
$vmProvState = (Get-AzVM -ResourceGroupName $ResGroup -Name $vm.name -Status).Statuses[1].Code
if($vmProvState -like '*running*'){
## Run Script on each SQL VM
Write-Host $vm.Name
try {
$Comm = (Invoke-AzVMRunCommand -ResourceGroupName $ResGroup -Name $vm.name -CommandId 'RunPowerShellScript' -ScriptPath $SPath).Value[0] | Select-Object -ExpandProperty Message | Out-String
$SQLArray += $Comm 
}
catch
    {
     Write-Host "Inst Step Error $error[0]"
     $SQLArray += $error[0]
    }
Write-Host "$($vm.Name) Instance Done"
try{ 
$Comm2 = (Invoke-AzVMRunCommand -ResourceGroupName $ResGroup -Name $vm.name -CommandId 'RunPowerShellScript' -ScriptPath $SPath2).Value[0] | Select-Object -ExpandProperty Message | Out-String 
$SQLArray += $Comm2
}
catch
    {
    Write-Host "DB Step Error $error[0]"
     $SQLArray += $error[0]
    }
Write-Host "$($vm.Name) DBs Done"
 }}}}
}

###############################
 $SQLArray | Out-File -FilePath $FileName -Encoding default

