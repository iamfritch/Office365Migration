<#
.SYNOPSIS
Change users passwords in bulk for Office 365.

.DESCRIPTION
this will change the password for all users to a default of 'P@$$w0rd'.

.PARAMETER password
Can be used to specify a different default password to set, but will use 'P@$$w0rd' if one is not given.

.PARAMETER changePasswordAtLogin
Specify whether the user will be required to change their password on login.  By default this is true.

.EXAMPLE
Change-Passwords.ps1 -userOU 'CN=Users,DC=example,DC=local' -password 'Ch@ngeM3'
#>

param (
    [string]$password = 'P@$$w0rd',
    [bool]$changePasswordAtLogin = $true
)
$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$users = Get-MsolUser
foreach ($user in $users) {
    Write-Host "Changing Password for $($user.UserPrincipalName)"
    if ($changePasswordAtLogin) {
        Set-MsolUserPassword -userPrincipalName $user.UserPrincipalName –NewPassword $securePassword -ForceChangePassword $true
    } else {
        Set-MsolUserPassword -userPrincipalName $user.UserPrincipalName –NewPassword $securePassword -ForceChangePassword $false
    }
}