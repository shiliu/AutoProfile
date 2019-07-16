<#
.SYNOPSIS
Gets the root path for SynologyDrive

.DESCRIPTION

.EXAMPLE

#>

# References:
# 1. Below are the list of predefined vars that can be used:
#    - $PSScriptRoot		[System defined] The folder path for current scipt file, NOT the caller script to call this function

# Note: $PSScriptRoot is always the folder for current scipt file, NOT the caller script to call this function
$SynologyDriveRoot = $ENV:SynologyDriveRoot
if (-not [string]::IsNullOrWhiteSpace($SynologyDriveRoot)){
    if (Test-Path $SynologyDriveRoot){ return $SynologyDriveRoot }
}

$possibleSynologyDriveParents = @("$ENV:USERPROFILE") -join ";"
$possibleSynologyDriveNames = @("SynologyDrive") -join ";"

$SynologyDriveRoot = Get-FirstExistedPath -PathPart1 $possibleSynologyDriveParents -PathPart2 $possibleSynologyDriveNames
if (-not [string]::IsNullOrWhiteSpace($SynologyDriveRoot)){
    [Environment]::SetEnvironmentVariable("SynologyDriveRoot", $SynologyDriveRoot, [EnvironmentVariableTarget]::User)
}

return $SynologyDriveRoot