##GPO Gather - Master Script
Connect-AzureAD

##Replace DRIVE_LOCATION with your drive path e.g. C:\Powershell
$GPOfile="DRIVE_LOCATION\GPO-Results.csv"

##Replace SUBSCRIPTION_MASK with mask for your subscriptions, if needed. If not needed, remove Where-Object section
 $subs = Get-AzSubscription | Where-Object -Property State -eq 'Enabled' | Where-Object -Property Name -like ('*SUBSCRIPTION_MASK') | Select-Object -Property Name
 
  $SubsArray = @()
  $GPOArray = @()
##Replace DRIVE_LOCATION with your drive path e.g. C:\Powershell, however Get-GPOs-Remote-Script.ps1 must be in that location
  $SPath = "DRIVE_LOCATION\Get-GPOs-Remote-Script.ps1"

foreach ($subs in $subs)
{
 $subs1 = ($subs).Name -replace ".{4}$"
 $SubsArray += $subs1
 }

 foreach ($SubsArray in $SubsArray)
 {
 $Sargs = ConvertFrom-StringData -StringData "sub=$SubsArray"
 ##Replace DC_RSG_NAME with the resource group name which contains the top-most level Domain Controller/AD Server to which you are connecting
 ##Replace DC_VM_NAME with the Domain Controller/AD Virtual Machine/Device name
 $GPOResult = Invoke-AzVMRunCommand -ResourceGroupName "DC_RSG_NAME" -Name "DC_VM_NAME" -CommandId 'RunPowerShellScript' -ScriptPath $SPath -Parameter $Sargs
 $GPOArray += $GPOResult.Value.Message
 }
###############################
 $GPOArray | Out-File -FilePath $GPOFile -Encoding default
