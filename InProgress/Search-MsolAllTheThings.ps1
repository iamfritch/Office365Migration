<#
.SYNOPSIS
Checks through all of an office account for a string.

.DESCRIPTION
Will grab all objects from a Office 365 account and display anything that matches a specific string which will by default search for something that includes 'local'.
Also gives the option of saving the results to a file.

.PARAMETER searchString
This is the string that we are comparing to and will display anything that matches it.  If it is not specified then nothing will be searched for but the results of the full scan can still be saved.

.PARAMETER saveAll
Tell the script if you want to save everything found and save to the file specified.

.PARAMETER saveResults
Tell the script if you want to save everything that matched the searchString paramater and save to the file specified.

.EXAMPLE
Search-MsolAllTheThings.ps1 -searchString 'searchCriteria'.
#>

param (
    [string]$searchString = '',
    [string]$saveAll = '',
    [string]$saveResults = ''
)

$users = Get-MsolUser -all
$deletedUsers = Get-MsolUser -All -ReturnDeletedUsers
$groups = Get-MsolGroup -All
$contacts = Get-MsolContact -All
$recipients = Get-Recipient -ResultSize unlimited
$softDeletedUsers = Get-MailUser -SoftDeletedMailUser
$softDeletedMailboxs = Get-Mailbox -SoftDeletedMailbox
$all = $users + $deletedUsers + $groups + $contacts + $recipients + $softDeletedUsers + $softDeletedMailboxs
if ($searchString -ne '') {
    $searchString = "*$searchString*"
    $results = $all | ?{$_.EmailAddress -like $searchString -or $_.UserPrincipalName -like $searchString -or $_.ProxyAddresses -like $searchString}
    Write-Output $results
    if ($saveResults) {
        $results | Out-File $saveResults
    }
}
if ($saveAll) {
    $all | Out-File $saveResults
}