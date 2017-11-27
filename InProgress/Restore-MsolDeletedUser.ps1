#Create Shared Mailbox
$NameSharedMailbox = Read-Host -Prompt "Enter The Shared Mailbox Name"
New-Mailbox -Shared -Name $NameSharedMailbox -DisplayName $NameSharedMailbox -Alias $NameSharedMailbox
$ShareMailboxGetGUID = Get-Mailbox -Identity $NameSharedMailbox

#Pick Deleted Mailbox To Restore
$mailboxtoRestore = Get-Mailbox -SoftDeletedMailbox | Select Name,PrimarySMTPAddress,DistinguishedName | Sort-Object Name | Out-GridView -Title "Current Softdeleted Mailbox List" -PassThru

#Command to restore deleted mailbox to new shared mailbox.
New-MailboxRestoreRequest -SourceMailbox $mailboxtoRestore.DistinguishedName -TargetMailbox $ShareMailboxGetGUID.PrimarySmtpAddress -AllowLegacyDNMismatch

#Grab the restore ID for the one you want progress on.
$RestoreProgress = Get-MailboxRestoreRequest | Select Name,TargetMailbox,Status,RequestGuid | Out-GridView -Title "Restore Request List" -PassThru

# Get the progress in Percent complete
Get-MailboxRestoreRequestStatistics -Identity $RestoreProgress.RequestGuid | Select Name,StatusDetail,TargetAlias,PercentComplete