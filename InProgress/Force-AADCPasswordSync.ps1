<#
.SYNOPSIS
Force a password sync through AADC.

.DESCRIPTION
This will force Azure Active Directory Connect to force a password sync, usually when you see errors with the password sync

.PARAMETER name
an explanation of a specific parameter. Replace name with the parameter name. You can have one of these sections for each parameter the script or function uses.

.EXAMPLE
Force-AADCPasswordSync.ps1 -sourceConnector 'source' -targetConnector 'target'
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$sourceConnector,
    [Parameter(Mandatory=$true)]
    [string]$targetConnector
)

Import-Module adsync

$globalSettings = Get-ADSyncGlobalSettings
$policy = New-Object Microsoft.IdentityManagement.PowerShell.ObjectModel.ConfigurationParameter "Microsoft.Synchronize.SynchronizationPolicy", String, SynchronizationGlobal, $null, $null, $null
$policy.Value = "Delta"
$globalSettings.Parameters.Remove($policy.Name)
$globalSettings.Parameters.Add($policy)

Set-ADSyncGlobalSettings -GlobalSettings $globalSettings

$sourceConnectorChanges = Get-ADSyncConnector -Name $sourceConnector
$policy = New-Object Microsoft.IdentityManagement.PowerShell.ObjectModel.ConfigurationParameter “Microsoft.Synchronize.ForceFullPasswordSync”, String, ConnectorGlobal, $null, $null, $null
$policy.Value = 1
$sourceConnectorChanges.GlobalParameters.Remove($policy.Name)
$sourceConnectorChanges.GlobalParameters.Add($policy)
$sourceConnectorChanges = Add-ADSyncConnector -Connector $sourceConnectorChanges

Set-ADSyncAADPasswordSyncConfiguration -SourceConnector $sourceConnector -TargetConnector $targetConnector -Enable $false
Set-ADSyncAADPasswordSyncConfiguration -SourceConnector $sourceConnector -TargetConnector $targetConnector -Enable $true