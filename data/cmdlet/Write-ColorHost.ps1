<#
.SYNOPSIS
Write host with color tag inside output string.

.DESCRIPTION
A new way to write host with color by adding color tag inside output string. 
    1. All colors in Write-Host can also be used as tag here. 
       E.g.: Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, DarkYellow, Gray, DarkGray, Blue, Green, Cyan, Red, Magenta, Yellow, White
    2. Color tag is case insensitive.

.PARAMETER str
The string with color tags to write.

.PARAMETER NoNewLine
Specifies that the content displayed in the console does not end with a newline character.

.EXAMPLE
Write-ColorHost "This is an <RED>single</RED> tag example!"
Write-ColorHost "This is an <Red>multi</Red> <Green>tags</Green> example!"
Write-ColorHost "This is <Blue>an <Red>nested</Red> tags example</Blue>!"

#>

# References:
# 1. Below are the list of predefined vars that can be used:
#    - $PSScriptRoot		[System defined] The folder path for current scipt file, NOT the caller script to call this function

param
(
    [Parameter(Position=0)]
    [string] $str,
    [switch] $NoNewLine
)

$colorTagRegex = '(<\/?(?:Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White)>)'
$colorStack = New-Object 'system.collections.generic.stack[string]'
$curColor = ''

[regex]::Split($str, $colorTagRegex, 1) | % {
    if ([regex]::IsMatch($_, $colorTagRegex, 1))
    {
        $color = $_ -replace '[<>\/]'
        if ($_ -like '</*>')
        {
            $curColor = if ($colorStack.Count -gt 0) { $colorStack.Pop() } else { '' }
        }
        else
        {
            $colorStack.Push($curColor)
            $curColor = $color
        }
    }
    else
    {
        if ([string]::IsNullOrWhiteSpace($curColor)) { Write-Host $_ -NoNewline } else { Write-Host $_ -NoNewline -ForegroundColor $curColor }
    }
}

if (-not $NoNewLine) { Write-Host '' }