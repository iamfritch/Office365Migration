<#
.SYNOPSIS
Adds a non-primary proxy addresses as specified by user input.

.DESCRIPTION
Takes the input of addressToAdd and adds it to all users proxyAddress as a secondary proxyAddress.

.PARAMETER userOU
Can be used to specify which ou to change the password for, or to change it for all users if not specified.

.PARAMETER addressToAdd
The address that we are adding.

.PARAMETER filter
Used when you want to specify a filter for the Get-ADUser command.

.EXAMPLE
Add-ADLocalAliases.ps1 -addressToAdd 'username@domain.tld'
#>

param (
    [string]$userOU = '',
    [Parameter(Mandatory=$true)]
    [string]$addressToAdd,
    [string]$filter = '*'
)

if ($userOU) {
    $users = Get-ADUser -Filter $filter -SearchBase $userOU -Properties ProxyAddresses, SamAccountName, UserPrincipalName
} else {
    $users = Get-ADUser -Filter $filter -Properties ProxyAddresses, SamAccountName, UserPrincipalName
}

Write-Output "`n"
Foreach ($user in $users) {
    $saveChanges = $false
    if (-not $user.proxyAddresses) {
        Write-Output "Proxy addresses for $($user.UserPrincipalName) were empty, you need a primary proxy address first`n"
    }
    ForEach ($proxy in $user.ProxyAddresses) {
        if ($proxy -eq "smtp:$($user.SamAccountName)@$($addressToAdd)") {
            Write-Output "User $($user.UserPrincipalName) has $($addressToAdd) as their secondary Proxy Address already`n"
        } elseif ($proxy -eq "SMTP:$($user.SamAccountName)@$($addressToAdd)") {
            Write-Output "User $($user.UserPrincipalName) has $($addressToAdd) as their primary Proxy Address already`n"
        } else {
            $user.ProxyAddresses.Add("smtp:$($user.UserPrincipalName)@$($addressToAdd)")
            $saveChanges = $true
        }
    }
    if ($saveChanges) {
        Set-ADUser -Instance $user
        $saveChanges = $false
        Write-Output "Added $($addressToAdd) to user $($user.UserPrincipalName)`n"
    }
}