# References:
# 1. Below are the list of predefined vars that can be used:
#    - $PSScriptRoot		[System defined] The folder path for current scipt file, NOT the caller script to call this function

Import-Module -Name liushi -WarningAction Ignore
Set-Alias -Name g -Value Goto-OnCallScripts
Set-Alias -Name t -Value Run-Torus

# For MS corp environment, customize the path to save variables to OnCallScripts folder
if ([string]::IsNullOrWhiteSpace($ENV:PsVarsSaveFolder) -and (-not [string]::IsNullOrEmpty($OnCallScriptFolderPath))){ $ENV:PsVarsSaveFolder = Join-Path $OnCallScriptFolderPath "PsVarsSaveFolder"}