<#
.SYNOPSIS
Remove any non-primary proxy addresses with a .local TLD.

.DESCRIPTION
Remove any non-primary proxy addresses with a .local TLD. Works off the whole forest rather then specifying an OU. Cannot remove a .local domain that is set as primary. Instead they would need to be swapped for a secondary first.

.PARAMETER filter
Used when you want to specify a filter for the Get-ADUser command.

.EXAMPLE
Remove-LocalAliases.ps1
#>

param (
    [string]$filter = '*'
)

$users = Get-ADUser -Filter $filter -Properties EmailAddress, ProxyAddresses, SamAccountName, UserPrincipalName | ft EmailAddress, ProxyAddresses, SamAccountName, UserPrincipalName
$saveChanges = $false
Write-Output "`n`n"
Foreach ($user in $users) {
    ForEach ($proxy in $user.ProxyAddresses) {
        if ($proxy -like 'smtp*.local') {
            $user.ProxyAddresses.Remove($proxy)
            $saveChanges = $true
        } elif ($proxy -like 'SMTP*.local') {
            Write-Output "User $($user.UserPrincipalName) has a .local domain as their primary and cannot be removed`nPlease swap for a secondary domain first and then run this command again`n"
        }
    }
    if ($saveChanges) {
        Set-ADUser -Instance $user
        $saveChanges = $false
        Write-Output "Removed .local domain from user $($user.UserPrincipalName)`n"
    }
}