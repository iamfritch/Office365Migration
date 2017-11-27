<#
.SYNOPSIS
Change users passwords in bulk for Active Directory.

.DESCRIPTION
Allows you to specify an OU and then changes the password to a default of 'P@$$w0rd'.

.PARAMETER userOU
Can be used to specify which ou to change the password for, or to change it for all users if not specified.

.PARAMETER password
Can be used to specify a different default password to set, but will use 'P@$$w0rd' if one is not given.

.PARAMETER changePasswordAtLogin
Specify whether the user will be required to change their password on login.  By default this is true.

.PARAMETER filter
Used when you want to specify a filter for the Get-ADUser command.

.EXAMPLE
Change-Passwords.ps1 -userOU 'CN=Users,DC=example,DC=local' -password 'Ch@ngeM3'
#>

param (
    [string]$userOU = '',
    [string]$password = 'P@$$w0rd',
    [bool]$changePasswordAtLogin = $true,
    [string]$filter = '*'
)
$password = $password | ConvertTo-SecureString -AsPlainText -Force
if ($userOU) {
    $users = Get-ADUser -Filter $filter -SearchBase $userOU -Properties EmailAddress, ProxyAddresses, SamAccountName, UserPrincipalName | ft EmailAddress, ProxyAddresses, SamAccountName, UserPrincipalName
} else {
    $users = Get-ADUser -Filter $filter -Properties EmailAddress, ProxyAddresses, SamAccountName, UserPrincipalName | ft EmailAddress, ProxyAddresses, SamAccountName, UserPrincipalName
}
foreach ($user in $users) {
    Write-Host "Changing Password for $($user.UserPrincipalName) with login $($user.SamAccountName)"
    if ($changePasswordAtLogin) {
        Set-ADAccountPassword $user.SamAccountName -NewPassword $password | Set-ADuser -ChangePasswordAtLogon $true
    }
    else {
        Set-ADAccountPassword $user.SamAccountName -NewPassword $password | Set-ADuser -ChangePasswordAtLogon $false
    }
}