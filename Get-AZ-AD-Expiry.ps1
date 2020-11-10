###Log Into Azure
Connect-AzureAD
###Create Array for Results
$results = @()
###Query Azure AD ##Replace "SEARCH TEXT STRING" With Naming Mask for Target Service Principal Accounts
Get-AzureADApplication -SearchString 'SEARCH TEXT STRING' -All $true | %{  
                             $app = $_

                             $owner = Get-AzureADApplicationOwner -ObjectId $_.ObjectID -Top 1

                             $app.PasswordCredentials | 
                                %{ 
                                    $results += [PSCustomObject] @{
                                            CredentialType = "PasswordCredentials"
                                            DisplayName = $app.DisplayName; 
                                            ExpiryDate = $_.EndDate;
                                            StartDate = $_.StartDate;
                                            KeyID = $_.KeyId;
                                            Type = 'NA';
                                            Usage = 'NA';
                                            Owners = $owner.UserPrincipalName;
                                        }  
                                 } 
                                  
                             $app.KeyCredentials | 
                                %{ 
                                    $results += [PSCustomObject] @{
                                            CredentialType = "KeyCredentials"                                        
                                            DisplayName = $app.DisplayName; 
                                            ExpiryDate = $_.EndDate;
                                            StartDate = $_.StartDate;
                                            KeyID = $_.KeyId;
                                            Type = $_.Type;
                                            Usage = $_.Usage;
                                            Owners = $owner.UserPrincipalName;
                                        }
                                 }                            
                          } 
                                                                                
$results | FT -AutoSize 

### Optionally export to a CSV file, Replace DRIVE_LOCATION with your drive path e.g. C:\Powershell
$results | Export-Csv -Path "DRIVE_LOCATION\AppsInventory.csv" -NoTypeInformation 