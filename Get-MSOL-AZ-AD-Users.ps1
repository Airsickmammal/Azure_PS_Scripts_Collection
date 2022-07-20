###Log Into Azure
Connect-MsolService
###Create Arrays for Results
$Usrs = @()
###Query Azure AD ##Replace "SEARCH TEXT STRING" With Naming Mask for Target User Principal Accounts
#Get-MsolUser | gm -MemberType Properties ##Query (Left) Can be Used to Get Column Names For Below Query
Get-MsolUser -EnabledFilter EnabledOnly | Where-Object {($_.UserPrincipalName -notlike "*SEARCH TEXT STRING*")} |
%{
$Usrs += [PSCustomObject] @{ 
                                            UserPrincipalName = $_.UserPrincipalName;
                                            DisplayName = $_.DisplayName;
                                            IsLicensed = $_.IsLicensed;
                                            LastPasswordChangeTimestamp = $_.LastPasswordChangeTimestamp;
                                            PasswordNeverExpires = $_.PasswordNeverExpires;
                                            UserType = $_.UserType;
                                            WhenCreated = $_.WhenCreated;
                                            LastDirSyncTime = $_.LastDirSyncTime;
                                            ##City = $_.City; 
                                            ##Department = $_.Department;
                                            ##LicenseAssignmentDetails = $_.LicenseAssignmentDetails;
                                            ##Licenses = $_.Licenses;
                                            ##PasswordNeverExpires = $_.PasswordNeverExpires;
                                            ##PreferredDataLocation = $_.PreferredDataLocation;
                                            ##ProxyAddresses = $_.ProxyAddresses;
                                            ##SoftDeletionTimestamp = $_.SoftDeletionTimestamp;
                                            ##StrongAuthenticationProofupTime = $_.StrongAuthenticationProofupTime;
                                            ##StrongPasswordRequired = $_.StrongPasswordRequired;
                                            ##StsRefreshTokenValidFrom = $_.StsRefreshTokenValidFrom;
                                            ##UsageLocation = $_.UsageLocation;
                                            ##ValidationStatus = $_.ValidationStatus;
                                            ##State =$_.State;
                                            Enabled = "TRUE";
                                        }}

Get-MsolUser -EnabledFilter DisabledOnly | Where-Object {($_.UserPrincipalName -notlike "*SEARCH TEXT STRING*")} |
%{
$Usrs += [PSCustomObject] @{ 
                                            UserPrincipalName = $_.UserPrincipalName;
                                            DisplayName = $_.DisplayName;
                                            IsLicensed = $_.IsLicensed;
                                            LastPasswordChangeTimestamp = $_.LastPasswordChangeTimestamp;
                                            PasswordNeverExpires = $_.PasswordNeverExpires;
                                            UserType = $_.UserType;
                                            WhenCreated = $_.WhenCreated;
                                            LastDirSyncTime = $_.LastDirSyncTime;
                                            ##City = $_.City; 
                                            ##Department = $_.Department;
                                            ##LicenseAssignmentDetails = $_.LicenseAssignmentDetails;
                                            ##Licenses = $_.Licenses;
                                            ##PasswordNeverExpires = $_.PasswordNeverExpires;
                                            ##PreferredDataLocation = $_.PreferredDataLocation;
                                            ##ProxyAddresses = $_.ProxyAddresses;
                                            ##SoftDeletionTimestamp = $_.SoftDeletionTimestamp;
                                            ##StrongAuthenticationProofupTime = $_.StrongAuthenticationProofupTime;
                                            ##StrongPasswordRequired = $_.StrongPasswordRequired;
                                            ##StsRefreshTokenValidFrom = $_.StsRefreshTokenValidFrom;
                                            ##UsageLocation = $_.UsageLocation;
                                            ##ValidationStatus = $_.ValidationStatus;
                                            ##State =$_.State;
                                            Enabled = "FALSE";
                                        }}
##Export Array to XLSX Excel File ##Replace [LOCATION] With Target Folder For Export File Location                                     
$Usrs | Sort-Object -Property DisplayName | Export-Csv C:\[LOCATION]\MSOUsersList-$(Get-Date -UFormat "%Y-%m-%d_%H-%M-%S").csv -NoTypeInformation
