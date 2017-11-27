<#
.SYNOPSIS
Changes all users primary proxyAddress.

.DESCRIPTION
Changes all users primary proxyAddress to the input of addressToChange as long as it is not already set as that and they don't already have it as a secondary.

.PARAMETER userOU
Used when you want to specify an OU to make the changes to.

.PARAMETER filter
Used when you want to specify a filter for the Get-ADUser command.

.EXAMPLE
Set-ADPrimaryProxyAddressByEmailAddress.ps1
#>

param (
    [string]$userOU = '',
    [string]$filter = '*'
)

if ($userOU) {
    $users = Get-ADUser -Filter $filter -SearchBase $userOU -Properties ProxyAddresses, SamAccountName, UserPrincipalName
} else {
    $users = Get-ADUser -Filter $filter -Properties ProxyAddresses, SamAccountName, UserPrincipalName
}

Write-Output "`n"
Foreach ($user in $users) {
    $primaryProxyAddress = ''
    ForEach ($proxy in $user.ProxyAddresses) {
        if ($proxy -like "SMTP:*") {
            $primaryProxyAddress = $proxy
        }
    }
    if ($primaryProxyAddress -like "SMTP:$($user.EmailAddress)") {
        write-Output "Primary proxy address is already updated to $($user.UserPrincipalName)"
    } else {
        if($primaryProxyAddress) {
            $user.ProxyAddresses.Remove($primaryProxyAddress)
        }
        $user.ProxyAddresses.Add("SMTP:$($user.EmailAddress)") > $null
        Write-Output "Changing main proxy address to SMTP:$($user.EmailAddress) for user $($user.UserPrincipalName)`n"
        Set-ADUser -Instance $user
        Write-Output "Changes saved`n"
    }
}