<#
Ref: https://blogs.msdn.microsoft.com/powershell/2006/12/07/resolve-error/
#>

# References:
# 1. Below are the list of predefined vars that can be used:
#    - $PSScriptRoot		[System defined] The folder path for current scipt file, NOT the caller script to call this function

param(
    [Parameter(Position=0)]
    [System.Management.Automation.ErrorRecord] $ErrorRecord=$Error[0]
)

$ErrorRecord | Format-List * -Force
$ErrorRecord.InvocationInfo |Format-List *
$Exception = $ErrorRecord.Exception
for ($i = 0; $Exception; $i++, ($Exception = $Exception.InnerException))
{   
    "$i" * 80
    $Exception |Format-List * -Force
}