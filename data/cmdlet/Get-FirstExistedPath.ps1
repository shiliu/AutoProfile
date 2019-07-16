<#
.SYNOPSIS
Find the first exists path which is a combination of path part 1 and part 2.

.DESCRIPTION

.PARAMETER PathPart1
The list of path part 1 which are separated by ";"

.PARAMETER PathPart2
The list of path part 1 which are separated by ";"

.EXAMPLE

#>

# References:
# 1. Below are the list of predefined vars that can be used:
#    - $PSScriptRoot		[System defined] The folder path for current scipt file, NOT the caller script to call this function

param(
    [Parameter(Position=0)]
    [string] $PathPart1,

    [Parameter(Position=1)]
    [string] $PathPart2
)

$part1List = $PathPart1 -split ";"
$part2List = $PathPart2 -split ";"

for ($i = 0; $i -lt $part1List.Count; $i++){
    for ($j = 0; $j -lt $part2List.Count; $j++){
        $fullPath = Join-Path $part1List[$i] $part2List[$j] -ErrorAction Ignore
        if (-not [string]::IsNullOrWhiteSpace($fullPath)){
            if (Test-Path $fullPath){
                return Join-Path $fullPath "." -Resolve
            }
        }
    }
}

return ""