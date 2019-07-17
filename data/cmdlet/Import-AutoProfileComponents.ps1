<#
.SYNOPSIS

.DESCRIPTION

.EXAMPLE

#>

# References:
# 1. Below are the list of predefined vars that can be used:
#    - $PSScriptRoot		[System defined] The folder path for current scipt file, NOT the caller script to call this function

param(
    [switch] $IncludeCommands,
    [switch] $IncludeBin,
    [switch] $IncludePsProfiles,
    [switch] $IncludeOsProfiles
)

if ((-NOT $IncludeCommands) -AND (-NOT $IncludeBin) -AND (-NOT $IncludePsProfiles) -AND (-NOT $IncludeOsProfiles)) { return }

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
    if ($IncludeCommands)
    {
        $curFolder = Join-Path $_ "Commands"
        if (Test-Path $curFolder)
        {
            Get-ChildItem $curFolder -Filter "*.ps1" | ? { -not ( $_.Name -like "Template.ps1") } | % {
                $fileName = $_.VersionInfo.FileName
                try {
                    . "$PSScriptRoot\Import-Ps1AsCommand.ps1" $fileName -Scope Global
                }
                catch {
                    Write-Host "Failed to import cmdlet from $fileName with error: $_" -ForegroundColor Red
                }
            }
        }
    }

    # bin
    if ($IncludeBin)
    {
        $curFolder = Join-Path $_ "bin"
        if (Test-Path $curFolder)
        {
            . "$PSScriptRoot\Add-PathToEnvVar.ps1" -Path $curFolder -Container User
        }
    }

    # OsProfiles
    if ($IncludeOsProfiles)
    {
        $indexScript = Join-Path $_ "OsProfiles\PowerShell\index.ps1"
        if (Test-Path $indexScript)
        {
            try {
                . "$indexScript"
            }
            catch {
                Write-Host "Failed to run OsProfile with error: $_" -ForegroundColor Red
            }
        }
    }
    
    # PsProfiles
    if ($IncludePsProfiles)
    {
        $indexScript = Join-Path $_ "PsProfiles\index.ps1"
        if (Test-Path $indexScript)
        {
            try {
                . "$indexScript"
            }
            catch {
                Write-Host "Failed to run PsProfile with error: $_" -ForegroundColor Red
            }
        }
    }
}