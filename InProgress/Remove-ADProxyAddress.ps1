<#
.SYNOPSIS
Remove a non-primary proxy addresses as specified by user input.

.DESCRIPTION
Takes the input of addressToRemove and removes it from all users proxyAddress as long as it's not their primary proxyAddress.

.PARAMETER addressToRemove
The address that we are removing.

.PARAMETER filter
Used when you want to specify a filter for the Get-ADUser command.

.EXAMPLE
Remove-ADLocalAliases.ps1 -addressToRemove 'username@domain.tld'
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$addressToRemove,
    [string]$filter = '*'
)

$users = Get-ADUser -Filter $filter -Properties EmailAddress, ProxyAddresses, SamAccountName, UserPrincipalName | Format-Table EmailAddress, ProxyAddresses, SamAccountName, UserPrincipalName
$saveChanges = $false
Write-Output "`n`n"
Foreach ($user in $users) {
    ForEach ($proxy in $user.ProxyAddresses) {
        if ($proxy -eq "smtp:$($addressToRemove)") {
            $user.ProxyAddresses.Remove("smtp:$($addressToRemove)")
            $saveChanges = $true
        } elif ($proxy -eq "SMTP:$($addressToRemove)") {
            Write-Output "User $($user.UserPrincipalName) has $($addressToRemove) as their primary Proxy Address and cannot be removed`n  Please swap for a secondary domain first and then run this command again`n"
        } else {
            Write-Output "I could not find the proxy address $($addressToRemove) for user $($user.UserPrincipalName)`n"
        }
    }
    if ($saveChanges) {
        Set-ADUser -Instance $user
        $saveChanges = $false
        Write-Output "Removed $($addressToRemove) from user $($user.UserPrincipalName)`n"
    }
}