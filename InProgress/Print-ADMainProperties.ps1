<#
.SYNOPSIS
Prints the main 3 properties of each user on Active Directory.

.DESCRIPTION
Prints the UserPrincipalName, SamAccountName, and EmailAddress for every user on Active Directory.

.EXAMPLE
Print-ADMainProperties.ps1
#>

$users = Get-ADUser -Filter * -Properties EmailAddress, ProxyAddresses, SamAccountName, UserPrincipalName | Format-Table EmailAddress, ProxyAddresses, SamAccountName, UserPrincipalName
Write-Output "`n`n"
Foreach ($user in $users) {
    Write-Output "UserPrincipalName: '$($user.UserPrincipalName)'`nSamAccountName:    '$($user.SamAccountName)'`nMail:              '$($user.EmailAddress)'`n"
}