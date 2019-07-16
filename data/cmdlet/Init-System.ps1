<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER <Name of parm 1>

.PARAMETER <Name of parm 2>

.EXAMPLE

#>

# References:
# 1. Below are the list of predefined vars that can be used:
#    - $PSScriptRoot		[System defined] The folder path for current scipt file, NOT the caller script to call this function

Write-ColorHost "<Cyan>Invoking starup scripts ...</Cyan>"
$Env:StartupScriptsPaths -split ";" | % { $_.Trim() } | ? { -NOT [string]::IsNullOrWhiteSpace($_) } | ? { Test-Path $_ } | % {
    Get-ChildItem -Recurse -Filter "*.ps1" -Path $_ | % {
        Write-Host "- $($_.FullName)"
        . "$($_.FullName)"
    }
}
