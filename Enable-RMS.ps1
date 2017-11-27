<#
.SYNOPSIS
Enable the Azure Rights Management services in Office 365.

.DESCRIPTION
Runs all the steps needed for enabling Azure Rights Management services in office 365 as well as creating a rule for encrypting messages by a keyword.

.PARAMETER safeword
This is the keyword that will cause the message to be encrypted.

.PARAMETER nameOfRule
The name of the rule to be created in Office 365.

.EXAMPLE
Enable-RMS.ps1 -safeword "Confidential"
#>

param (
    [string]$safeword = 'Encrypt',
    [string]$nameOfRule = 'RMS-EncryptionByKeyword'
)

# Activating Azure Rights Management
Connect-AadrmService
Enable-Aadrm

# Configure IRM to use Azure Rights Management
Set-IRMConfiguration -RMSOnlineKeySharingLocation "https://sp-rms.na.aadrm.com/TenantManagement/ServicePartner.svc"
Import-RMSTrustedPublishingDomain -RMSOnline -name "RMS Online"
Write-Output "First test"
Test-IRMConfiguration -RMSOnline
Read-Host -Prompt "Press enter to continue or CTRL+C to quit"
Set-IRMConfiguration -InternalLicensingEnabled $true
Write-Output "Second test"
Test-IRMConfiguration -RMSOnline
Read-Host -Prompt "Press enter to continue CTRL+C to quit"
# Create a Transport Protection Rule
New-TransportRule -Name $nameOfRule -SubjectContainsWords $safeword -ApplyOME $true
