<#
.SYNOPSIS
Changes all users UserPrincipalName.

.DESCRIPTION
Changes all users UserPrincipalName to the input of addressToChange as long as it is not already set as that and they don't already have it as a secondary.

.PARAMETER userOU
Used when you want to specify an OU to make the changes to.

.PARAMETER filter
Used when you want to specify a filter for the Get-ADUser command.

.PARAMETER saveChanges
Used when you want to save the changes.

.EXAMPLE
Change-ADLocalAliases.ps1 -addressToChange 'username@domain.tld'
#>

param (
    [string]$userOU = '',
    [string]$filter = '*',
    [switch]$saveChanges
)

if ($userOU) {
    $users = Get-ADUser -Filter $filter -SearchBase $userOU -Properties ProxyAddresses, SamAccountName, UserPrincipalName
} else {
    $users = Get-ADUser -Filter $filter -Properties ProxyAddresses, SamAccountName, UserPrincipalName
}

Write-Output "`n"
Foreach ($user in $users) {
    if ($user.UserPrincipalName -eq "$($user.EmailAddress)") {
        Write-Output "User Principal Name already set properly"
    } else {
        $user.UserPrincipalName = "$($user.EmailAddress)"
        Write-Output "Changing UPN to $($user.UserPrincipalName)"
    }

    if($saveChanges) {
        Set-ADUser -Instance $user
        Write-Output "Added $($addressToAdd) to user $($user.SamAccountName)`n"
    }
}