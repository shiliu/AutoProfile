<#
.SYNOPSIS
Expose a ps1 file as a command.

.DESCRIPTION


.PARAMETER Ps1Path
The path of the PS1 file.

.PARAMETER CommandName
The command name. If not specified, the file name will be used.

.PARAMETER Scope
The scope to expose the command. Default it is "Local".
Note: If expose the command in "Local" scope, please call this function with ".". Otherwise, the exposed command will be invisible 
    for the caller, as it is only exposed for the scope inside this function.

.EXAMPLE

#>

# References:
# 1. Below are the list of predefined vars that can be used:
#    - $PSScriptRoot		[System defined] The folder path for current scipt file, NOT the caller script to call this function

param(
    [Parameter(Position=0)]
    [string] $Ps1Path,

    [string] $CommandName,

    [ValidateSet("Global", "Local")]
    [string] $Scope = "Local"
)

if (($Ps1Path -like "*.ps1") -AND (Test-Path $Ps1Path))
{
    if ([string]::IsNullOrWhiteSpace($CommandName))
    {
        $fileName = Split-Path $Ps1Path -Leaf
        $CommandName = $fileName.Substring(0, $fileName.Length - 4)
    }

    $metaData = New-Object System.Management.Automation.CommandMetaData (Get-Command $Ps1Path)
    $proxy = [System.Management.Automation.ProxyCommand]::create($metaData)
    Invoke-Expression "function ${Scope}:$CommandName {`r`n${proxy}`r`n}"
}