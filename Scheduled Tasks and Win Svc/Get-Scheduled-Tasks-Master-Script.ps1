##Scheduled Tasks And Windows Services Gather
Connect-AzureAD

$FileNameDate = get-date -format yyyymmdd-hhmm
##Replace DRIVE_LOCATION with your drive path e.g. C:\Powershell
$FileName = "DRIVE_LOCATION\ScheduledTask-" +  $FileNameDate +  ".csv"
$FileName
##Replace DRIVE_LOCATION with your drive path e.g. C:\Powershell
$FileName2 = "DRIVE_LOCATION\WinServices.csv"

##Replace SUBSCRIPTION_MASK with mask for your subscriptions, if needed. If not needed, remove Where-Object section
 $subs = Get-AzSubscription | Where-Object -Property State -eq 'Enabled' | Where-Object -Property Name -like ('*SUBSCRIPTION_MASK') | Select-Object -Property Name

  $SCHArray = @()
  $SvcArray = @()
##Replace DRIVE_LOCATION with your drive path e.g. C:\Powershell, however Get-Scheduled-Tasks-Remote-Script.ps1 must be in that location
  $SPath = "DRIVE_LOCATION\Get-Scheduled-Tasks-Remote-Script.ps1"
##Replace DRIVE_LOCATION with your drive path e.g. C:\Powershell, however Get-Win-Svcs-Remote-Script.ps1 must be in that location
  $SvPath = "DRIVE_LOCATION\Get-Win-Svcs-Remote-Script.ps1"

foreach ($subs in $subs)
{
Write-Host $subs.Name
Select-AzSubscription -SubscriptionName $subs.Name | Out-null

 $ResGroup = (Get-azResourceGroup).ResourceGroupName
	foreach ($ResGroup in $ResGroup){
	
$vm = Get-azVM -ResourceGroupName $ResGroup
##Included this as an example for matching VM name masks
##Replace VM_MASK1, 2 and 3 with VM masks that you wish to target. Example if you distinguish between Application, Processing and Database servers/VMs
$VMNameParam = "VM_MASK1"
$VMNameParam1 = "VM_MASK2"
$VMNameParam2 = "VM_MASK3"
		   		
foreach ($vm in $vm) {                     

 if ($vm.Name -match $VMNameParam -or $vm.Name -match $VMNameParam1 -or $vm.Name -match $VMNameParam2) {  
$vmProvState = (Get-AzVM -ResourceGroupName $ResGroup -Name $vm.name -Status).Statuses[1].Code
##Ensure you are only targeting Running VMs
if($vmProvState -like '*running*'){
##Run Script on each VM
Write-Host $vm.Name
##Windows Scheduled Task Script
$Comm = (Invoke-AzVMRunCommand -ResourceGroupName $ResGroup -Name $vm.name -CommandId 'RunPowerShellScript' -ScriptPath $SPath).Value[0] | Select-Object -ExpandProperty Message | Out-String
$SCHArray += $Comm 
 Write-Host $SCHArray
##Windows Service Script
$Comm2 = (Invoke-AzVMRunCommand -ResourceGroupName $ResGroup -Name $vm.name -CommandId 'RunPowerShellScript' -ScriptPath $SvPath).Value[0] | Select-Object -ExpandProperty Message | Out-String
$SVCArray += $Comm2 
Write-Host $SVCArray
 }}}}
}

###############################
 $SCHArray | Out-File -FilePath $FileName -Encoding default
 $SVCArray | Out-File -FilePath $FileName2 -Encoding default

