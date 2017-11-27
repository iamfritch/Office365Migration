<#
.SYNOPSIS
Log into an Office 365 account.

.DESCRIPTION
Log into an Office 365 account.  If a username is not specified with the command, then it will be asked for.

.EXAMPLE
Login-Office365.ps1

.EXAMPLE
Login-Office365.ps1
#>

Import-Module MSOnline
$O365Credentials = Get-Credential
$O365Session = New-PSSession –ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $O365Credentials -Authentication Basic -AllowRedirection
Import-PSSession $O365Session -AllowClobber
Connect-MsolService –Credential $O365Credentials