<#
.SYNOPSIS
Check that the main 3 properties of each user on Active Directory matches.

.DESCRIPTION
Check that the UserPrincipalName, SamAccountName, and EmailAddress matches for every user on Active Directory.

.PARAMETER printCorrectaccounts
Use this if you want the script to print accounts that are set correctly. Otherwise they will not be printed.

.EXAMPLE
Check-ADMainProperties.ps1
#>

param (
    [bool]$printCorrectAccounts = $false
)

$users = Get-ADUser -Filter * -Properties EmailAddress, ProxyAddresses, SamAccountName, UserPrincipalName | Format-Table EmailAddress, ProxyAddresses, SamAccountName, UserPrincipalName
Write-Output "`n`n"
Foreach ($user in $users) {
    if ($user.UserPrincipalName){
        $domain = "@$($user.UserPrincipalName.Split('@')[1])"
    } else {
        $domain = ''
    }
    $samAccountNameDifferent = $false
    $emailAddressDifferent = $false
    $proxyAddressDifferent = $false

    if ($user.UserPrincipalName -ne "$($user.SamAccountName)$($domain)") {
        $samAccountNameDifferent = $true
    }
    if ($user.UserPrincipalName -ne $user.EmailAddress) {
        $emailAddressDifferent = $true
    }
    ForEach ($proxy in $user.ProxyAddresses) {
        if ($proxy -like 'SMTP*') {
            if ($user.UserPrincipalName -eq "SMTP:$($user.EmailAddress)") {
                $proxyAddressDifferent = $true
                break
            }
        }
    }
    if ($samAccountNameDifferent -or $emailAddressDifferent -or $proxyAddressDifferent -or $printCorrectAccounts) {
        Write-Output "User $($user.UserPrincipalName)"
        if ($samAccountNameDifferent) {
            Write-Output "Incorrect SamAccountName as follows: $($user.SamAccountName)"
        }
        if ($emailAddressDifferent) {
            Write-Output "Incorrect Mail as follows: $($user.EmailAddress)"
        }
        if ($proxyAddressDifferent) {
            ForEach ($proxy in $user.ProxyAddresses) {
                if ($proxy -like 'SMTP*') {
                    if ($user.UserPrincipalName -eq "SMTP:$($user.EmailAddress)") {
                        Write-Output "Incorrect Primary ProxyAddresses as follows: $proxy"
                        break
                    }
                }
            }
        }
        if ($printCorrectAccounts -and !$emailAddressDifferent -and !$proxyAddressDifferent -and !$printCorrectAccounts) {
            Write-Output "All account properties correct for $($user.UserPrincipalName)"
        }
        Write-Output "`n"
    }
}