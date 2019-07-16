<#
.SYNOPSIS
Set the value for the specified environment variable in specified container, and also the current process container.

.DESCRIPTION

.PARAMETER Name
The environment variable name.

.PARAMETER Value
The environment variable value.

.PARAMETER Target
The target container of environment variable.

.EXAMPLE

#>

# References:
# 1. Below are the list of predefined vars that can be used:
#    - $PSScriptRoot		[System defined] The folder path for current scipt file, NOT the caller script to call this function

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string] $Name,

    [Parameter(Position=1)]
    [string] $Value,

    [ValidateSet("Machine", "User", "Process")]
    [Parameter(Mandatory=$true)]
    [string] $Target
)

switch ($Target) {
    "Machine" { 
        [Environment]::SetEnvironmentVariable($Name, $Value, [EnvironmentVariableTarget]::Machine)
    }

    "User" { 
        [Environment]::SetEnvironmentVariable($Name, $Value, [EnvironmentVariableTarget]::User)
    }
}

[Environment]::SetEnvironmentVariable($Name, $Value, [EnvironmentVariableTarget]::Process) 