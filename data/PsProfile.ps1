# This will be executed for AutoProfile when power shell is initializing.

# References:
# 1. Below are the list of predefined vars that can be used:
#    - $PSScriptRoot		[System defined] The folder path for current scipt file, NOT the caller script to call this function

# Note: without this, the directly runnable code in module file (psm1) will not work and only directly defined function in that file will be imported
Import-Module -Name autoprofile -WarningAction Ignore

. Import-AutoProfileComponents -IncludePsProfiles

# PsReadLine
Write-ColorHost "[PsReadLine] <Green>CaptureScreen   Shift+Alt+C</Green>"
Set-PSReadlineKeyHandler -Chord Shift+Alt+C -Function CaptureScreen