<#
.SYNOPSIS
Add ProxyAddress to all users.

.DESCRIPTION
Adds the specified Proxy address to all users as long as it's not already added to that user.

.PARAMETER addressToRemove
Required, and used to specify the address to remove.

.EXAMPLE
Remove-MsolProxyAddress.ps1 -ass
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$addressToRemove
)

Foreach ($user in Get-Mailbox) {
    Write-Output "Removing $($addressToRemove) as a secondary for user $($user.UserPrincipalName)"
    Set-Mailbox -Identity $user.UserPrincipalName -EmailAddresses @{add="$($user.Alias)@$($addressToRemove)"}
}