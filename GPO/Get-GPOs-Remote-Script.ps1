Param(
   [Parameter(Mandatory=$true)][String]$sub
)

$argsa = $sub
$args2 = @()
$args2 += $argsa

$GPOobjs2 = @()
  
foreach ($args2 in $args2)
{
try
{
 $Customer = $args2
 ##Only need DOMAIN1 if you have a child domain, otherwise remove it and just use DOMAIN2, DOMAIN3
 ##Replace DOMAIN1, DOMAIN2, DOMAIN3 with your dc domain details e.g. "dc=MyChildDomain,dc=MainDomain,dc=com"
        $Target = "dc=$Customer,dc=DOMAIN1,dc=DOMAIN2,dc=DOMAIN3"
        $Domain = "$Customer.DOMAIN1.DOMAIN2.DOMAIN3"        
    $GetGPO=(Get-GPInheritance -Target $Target -Domain $Domain).gpolinks

    foreach ($GetGPO in $GetGPO)
    {
     $GPOInfo = [pscustomobject]@{
                 'Customer'=$Customer
                 'Name'=$GetGPO.DisplayName
                 'Enabled'=$GetGPO.Enabled
                 'Enforced'=$GetGPO.Enforced
                     }
                     $GPOobjs2 += $GPOInfo
   }            
   }
    catch
    {
        Write-Host $error[0]
    }
   }

$GPOobjs2 | Format-Table -HideTableHeaders | Out-Host