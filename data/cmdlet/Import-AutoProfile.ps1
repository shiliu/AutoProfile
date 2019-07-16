<#
.SYNOPSIS

.DESCRIPTION

.EXAMPLE

#>

# References:
# 1. Below are the list of predefined vars that can be used:
#    - $PSScriptRoot		[System defined] The folder path for current scipt file, NOT the caller script to call this function


#
# Gets the list of available auto profile folder list
#
$autoProfilePathList = @()

# SynologyDrive
$autoProfilePathList += "$(Get-SynologyDriveRoot)\App\AutoProfile"

# OneDrive
$autoProfilePathList += "$(Get-OneDriveRoot)\App\AutoProfile"

# OneDrive - Microsoft
$autoProfilePathList += "$(Get-OneDriveRoot Microsoft)\App\AutoProfile"

# ENV setting
if (-not [string]::IsNullOrWhiteSpace($ENV:AutoProfilePaths)) {
    $autoProfilePathList += $ENV:AutoProfilePaths -split ";"
}

# Remove all paths the do NOT exist
$autoProfilePathList = $autoProfilePathList | ? { -not [string]::IsNullOrWhiteSpace($_) } | ? { Test-Path $_ }

#
# Import the profile for each folder
#
$autoProfilePathList | % {
    # cmdlets
    $curCmdletFolder = Join-Path $_ "cmdlet"
    if (Test-Path $curCmdletFolder)
    {
        Get-ChildItem $curCmdletFolder -Filter "*.ps1" | ? { -not ( $_.Name -like "Template.ps1") } | % {
            $fileName = $_.VersionInfo.FileName
            try {
                . "$PSScriptRoot\Import-Ps1AsCommand.ps1" $fileName -Scope Global
            }
            catch {
                Write-Host "Failed to import cmdlet from $fileName with error: $_" -ForegroundColor Red
            }
        }
    }

    # bin
    $curBinFolder = Join-Path $_ "bin"
    if (Test-Path $curBinFolder)
    {
        . "$PSScriptRoot\Add-PathToEnvVar.ps1" -Path $curBinFolder -Container User
    }
}