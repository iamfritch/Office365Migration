<#
.SYNOPSIS
Display disk usage information.

.DESCRIPTION
This will display all the drives for the computer as well as display the disk size, free space, and used space.

.EXAMPLE
Get-DiskUsageInfo.ps1
#>

$Drives = Get-WmiObject Win32_LogicalDisk -Filter "DriveType = 3"
if ($Drives) {
    foreach ($Drive in $Drives) {
        $DriveSize=[math]::Round($Drive.Size/1GB)
        $FreeSpace = [math]::Round($Drive.FreeSpace/1GB)
        $Computer = Get-WmiObject Win32_ComputerSystem;
        $UsedSpace = $DriveSize - $FreeSpace;
        Write-Output "$($Drive.Name) in $($Computer.Name)`n`tDisk Size = $($DriveSize)GB`n`tFree = $($FreeSpace)GB`n`tUsed = $($UsedSpace)GB"
    }
} else {
    Write-Output "No Drives in computer???"
}
