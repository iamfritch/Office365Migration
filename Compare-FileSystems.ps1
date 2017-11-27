<#
.SYNOPSIS
Compares two file systems and returns the results based on parameters

.DESCRIPTION
This will take a log of two file systems and depending on which parameters you select, it will display just the files that are only in the source location.

.PARAMETER sourceLocation
The source location to compare against.

.PARAMETER destinationLocation
The destination that the source is being compared to.

.PARAMETER onlyPrintSource
This parameter will make this script only print the files that are in the source but not the destination.

.EXAMPLE
Compare-FileSystems.ps1 -sourceLocation 'C:\' -destinationLocation 'D:\'
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$sourceLocation,
    [Parameter(Mandatory=$true)]
    [string]$destinationLocation,
    [switch]$onlyPrintSource
)

$sourceObject = Get-ChildItem -Recurse -path $sourceLocation
$destinationObject = Get-ChildItem -Recurse -path $destinationLocation

$result = Compare-Object -PassThru -ReferenceObject $sourceObject -DifferenceObject $destinationObject
Foreach ($line in $result) {
    if ($onlyPrintSource) {
        if ($line.SideIndicator -eq '<=') {
            Write-Output $line.FullName
        }
    } else {
        $output = ''
        if ($line.SideIndicator -eq '<=') {
            $output = "<<`t"
        }
        if ($line.SideIndicator -eq '=>') {
            $output = ">>`t"
        }
        $output += $line.FullName
        Write-Output $output
    }
}