<#
.SYNOPSIS
Add a path to specified environment variable that holds a list of paths which are separated by ";".

.DESCRIPTION

.PARAMETER Path

.PARAMETER Container

.PARAMETER EnvVarName

.EXAMPLE

#>

# References:
# 1. Below are the list of predefined vars that can be used:
#    - $PSScriptRoot		[System defined] The folder path for current scipt file, NOT the caller script to call this function

param(
    [Parameter(Position=0)]
    [string] $Path,
    [ValidateSet('Machine', 'User', 'Process')]
    [string] $Container,
    [string] $EnvVarName = "Path"
)

$containerMapping = @{
    Machine = [EnvironmentVariableTarget]::Machine
    User = [EnvironmentVariableTarget]::User
    Process = [EnvironmentVariableTarget]::Process
}
$containerType = $containerMapping[$Container]

$persistedPaths = [Environment]::GetEnvironmentVariable($EnvVarName, $containerType) -split ';'
if ($persistedPaths -notcontains $Path) 
{
    $persistedPaths = $persistedPaths + $Path | ? { $_ }

    $newValue = $persistedPaths -join ';'
    [Environment]::SetEnvironmentVariable($EnvVarName, $newValue, $containerType)
    if ($Container -ne 'Process')
    {
        [Environment]::SetEnvironmentVariable($EnvVarName, $newValue, [EnvironmentVariableTarget]::Process)
    }
}
