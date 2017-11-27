<#
.SYNOPSIS
Changes all users primary proxyAddress.

.DESCRIPTION
Changes all users primary proxyAddress to the input of addressToChange as long as it is not already set as that and they don't already have it as a secondary.

.PARAMETER addressToChange
The address that we are changing to.

.PARAMETER filter
Used when you want to specify a filter for the Get-ADUser command.

.EXAMPLE
Change-ADLocalAliases.ps1 -addressToChange 'username@domain.tld'
#>

param (
    [string]$userOU = '',
    [Parameter(Mandatory=$true)]
    [string]$addressToChange,
    [string]$filter = '*'
)

if ($userOU) {
    $users = Get-ADUser -Filter $filter -SearchBase $userOU -Properties ProxyAddresses, SamAccountName, UserPrincipalName
} else {
    $users = Get-ADUser -Filter $filter -Properties ProxyAddresses, SamAccountName, UserPrincipalName
}

Write-Output "`n"
Foreach ($user in $users) {
    $proxyToRemove = ''
    ForEach ($proxy in $user.ProxyAddresses) {
        if ($proxy -like "SMTP:*") {
            $proxyToRemove = $proxy
        }
        if ($proxy -ceq "smtp:$($user.SamAccountName)@$($addressToChange)") {
            Write-Output "User $($user.UserPrincipalName) has $($addressToChange) as their secondary Proxy Address`n  Remove as a secondary address first, and then re-add as a primary again"
        } elseif ($proxy -ceq "SMTP:$($user.SamAccountName)@$($addressToChange)") {
            Write-Output "User $($user.UserPrincipalName) has $($addressToChange) as their primary Proxy Address already`n"
            $proxyToRemove = ''
        }
    }
    if (-not $user.proxyAddress) {
        write-Output "'$($user.proxyAddresses)'"
        Write-Output "Proxy addresses for $($user.UserPrincipalName) were empty"
        $user.ProxyAddresses.Add("SMTP:$($user.SamAccountName)@$($addressToChange)") > $null
        Write-Output "Changing main proxy address to SMTP:$($user.SamAccountName)@$($addressToChange) for user $($user.UserPrincipalName)`n"
        Set-ADUser -Instance $user
    } elseif ($proxyToRemove) {
        $user.ProxyAddresses.Remove($proxyToRemove)
        $user.ProxyAddresses.Add("SMTP:$($user.SamAccountName)@$($addressToChange)") > $null
        Write-Output "Changing main proxy address to SMTP:$($user.SamAccountName)@$($addressToChange) for user $($user.UserPrincipalName)`n"
        Set-ADUser -Instance $user
    }
}