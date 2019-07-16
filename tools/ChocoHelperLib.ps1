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
function Write-ColorHost
{
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
}

function Get-ProxyFunctionForScript
{
    param(
        [Parameter(Position=0)]
        [string] $ScriptFilePath,

        [Parameter(Position=1)]
        [string] $FunctionName
    )

    if (!(Test-Path $ScriptFilePath)) { return }

    $ScriptFilePath = Join-Path $ScriptFilePath "." -Resolve
    $scriptFileName = Split-Path $ScriptFilePath -Leaf
    if ([string]::IsNullOrWhiteSpace($FunctionName)) { $FunctionName = $scriptFileName.Substring(0, $scriptFileName.Length - 4) }

    $regexDocStart = '^\s*<#'
    $regexDocEnd = '#>\s*(#.*)?$'
    $regexOneLineDoc = '^\s*<#.*#>\s*(#.*)?$'

    # we only support param attribute in one line style. Note, we support multi attributes, but each one should be in one line.
    $regexParamAttributeDef = '^\s*\[CmdletBinding\(.*\)\s*\]\s*(#.*)?$'

    $regexParamStart = '^\s*param[\s\r\n]*(\(\s*)?$'
    $regexParamEnd = '\)\s*(#.*)?$'
    $regexOneLineParam = '^\s*param\s*\(.*\)\s*(#.*)?$'

    $regexFunctionDef = '^[ \t]*function'
    #$regexParmpart = '^\s*param\s*\((\s|[^(]|\(.*\))*?\)'

    $stage = "Start"
    $parmPart = ""

    Get-Content $ScriptFilePath | % {
        $curLine = $_
        switch ($stage)
        {
            "Start"
            {
                if ([Regex]::IsMatch($curLine, $regexOneLineDoc, 1)) { $stage = "OneLineDoc" }
                elseif ([Regex]::IsMatch($curLine, $regexDocStart, 1)) { $stage = "DocStart" }
                elseif ([Regex]::IsMatch($curLine, $regexParamAttributeDef, 1)) { $stage = "ParamAttribute" }
                elseif ([Regex]::IsMatch($curLine, $regexOneLineParam, 1)) { $stage = "OneLineParam" }
                elseif ([Regex]::IsMatch($curLine, $regexParamStart, 1)) { $stage = "ParamStart" }
                elseif ([Regex]::IsMatch($curLine, $regexFunctionDef, 1)) { $stage = "Finished" }
            }

            "Doc"
            {
                if ([Regex]::IsMatch($curLine, $regexDocEnd, 1)) { $stage = "DocEnd" }
            }

            "DocFinished"
            {
                if ([Regex]::IsMatch($curLine, $regexParamAttributeDef, 1)) { $stage = "ParamAttribute" }
                elseif ([Regex]::IsMatch($curLine, $regexOneLineParam, 1)) { $stage = "OneLineParam" }
                elseif ([Regex]::IsMatch($curLine, $regexParamStart, 1)) { $stage = "ParamStart" }
                elseif ([Regex]::IsMatch($curLine, $regexFunctionDef, 1)) { $stage = "Finished" }
            }

            "ParamAttribute"
            {
                if ([Regex]::IsMatch($curLine, $regexParamAttributeDef, 1)) { $stage = "ParamAttribute" }
                elseif ([Regex]::IsMatch($curLine, $regexOneLineParam, 1)) { $stage = "OneLineParam" }
                elseif ([Regex]::IsMatch($curLine, $regexParamStart, 1)) { $stage = "ParamStart" }
                elseif ([string]::IsNullOrWhiteSpace($curLine)) { return }
                else { throw "Not supported script format! Error at ParamAttribute starge."}
            }

            "Param"
            {
                if ([Regex]::IsMatch($curLine, $regexParamEnd, 1)) { $stage = "ParamEnd" }
            }
        }

        switch ($stage)
        {
            "OneLineDoc"
            {
                $curLine
                $stage = "DocFinished"
            }

            "DocStart"
            {
                $curLine
                $stage = "Doc"
            }

            "Doc"
            {
                $curLine
            }

            "DocEnd"
            {
                $curLine
                $stage = "DocFinished"
            }

            "ParamAttribute"
            {
                $parmPart += "    $curLine`r`n"
            }

            "OneLineParam"
            {
                $parmPart += "    $curLine`r`n"
                $stage = "Finished"
            }

            "ParamStart"
            {
                
                $parmPart += "    $curLine`r`n"
                $stage = "Param"
            }

            "Param"
            {
                $parmPart += "    $curLine`r`n"
            }

            "ParamEnd"
            {
                $parmPart += "    $curLine`r`n"
                $stage = "Finished"
            }
        }
    }

    "function $functionName"
    "{"
    if (![string]::IsNullOrWhiteSpace($parmPart)){ $parmPart }
    "    if (`$global:DebugMode){ Write-Host `"Invoking $ScriptFilePath`" }"
    "    . `"$ScriptFilePath`" @PSBoundParameters"
    "}"
    ""
    ""
}

function Inject-CodeBlock
{
    param(
        [string] $Target,
        [string] $CodeId,
        [string] $CodeBlock
    )

    # Remove the code block first if exists
    $Target = Remove-CodeBlock -Target $Target -CodeId $CodeId

    $Target += "# <$CodeId>`r`n"
    $Target += "$CodeBlock"
    $Target += "`r`n# </$CodeId>`r`n"
    return $Target
}

function Remove-CodeBlock
{
    param(
        [string] $Target,
        [string] $CodeId
    )

    $powerShellProfile -replace "(?ms)^(`r`n)*# <$CodeId>.*# </$CodeId>(`r`n)*","`r`n"
}

function Install-PsProfile
{
    param(
        [string] $CodeId,
        [string] $TargetScriptPath,
        [string] $Owner,
        [string] $Comment
    )

    if ([string]::IsNullOrWhiteSpace($TargetScriptPath)){return}

	$powerShellProfileDir = Join-Path $([Environment]::GetFolderPath("MyDocuments")) "WindowsPowerShell"
	$powerShellProfilePath = Join-Path $PowerShellProfileDir "Microsoft.PowerShell_profile.ps1"

	# Create a empty profile if it does not exists
	if (-not (Test-Path $powerShellProfilePath))
	{
		New-Item -Path $powerShellProfilePath -ItemType File -Force
	}

    $powerShellProfile = Get-Content $powerShellProfilePath -Raw
    
    if ([string]::IsNullOrWhiteSpace($Comment))
    {
        $codeBlock += "# $Comment"
    }
    
    $codeBlock += "if (Test-Path `"$TargetScriptPath`"){ . `"$TargetScriptPath`" }"
	Inject-CodeBlock -Target $powerShellProfile -CodeId $CodeId -CodeBlock $codeBlock | Set-Content $powerShellProfilePath
}


<#
.SYNOPSIS
    Install / reinstall a powershell module.

.DESCRIPTION
    Install / reinstall a powershell module. The existed module folder will be clean up first.

.RETURN
    N/A

.EXCEPTION
    N/A
#>
function Install-PsPackage
{
    param(
        [Parameter(Position=0)]
        [string] $PackageRoot,
        [string] $ModuleName,
        [string] $CmdletFolderName = "data\cmdlet",
        [string] $ProfileScriptName = "data\PsProfile.ps1"
    )

    if (!(Test-Path $PackageRoot -PathType Container)) { throw "PackageRoot `"$PackageRoot`" is not a valid folder." }

    $packageName = Split-Path $PackageRoot -Leaf
    if ([string]::IsNullOrWhiteSpace($ModuleName)) { $ModuleName = $packageName }

    $cmdletFolderPath = Join-Path $PackageRoot $CmdletFolderName
    $psProfileScriptPath = Join-Path $PackageRoot $ProfileScriptName

    Write-ColorHost "<Yellow>Installing package <Cyan>$packageName</Cyan> to PowerShell ...</Yellow>"

    #
    # Step 1: module part
    #
    if (Test-Path $cmdletFolderPath){
        # Create module folder if not exists.
        $moduleFolderPath = Join-Path $([Environment]::GetFolderPath("MyDocuments")) "WindowsPowerShell\Modules\$ModuleName"
        if (!(Test-Path $moduleFolderPath)) {
            New-Item -Path $moduleFolderPath -ItemType Directory | Out-Null
        }
        else {
            # Clean up old model files
            Remove-Item "$moduleFolderPath\*" -Recurse
        }

        # Create new module file
        $moduleFilePath = Join-Path $moduleFolderPath "$($ModuleName).psm1"
        Set-Content -Value "# Below cmdlets for module $ModuleName is auto extracted from $cmdletFolderPath" -Path $moduleFilePath
        Add-Content -Value "" -Path $moduleFilePath

        Get-ChildItem -Path $cmdletFolderPath -Filter "*.ps1" | % {
            if (-not ($_.Name -like "Template.ps1"))
            {
                $cmdletName = $_.Name.Substring(0, $_.Name.Length - 4)
                $proxyForScript = Get-ProxyFunctionForScript -ScriptFilePath $_.VersionInfo.FileName -FunctionName $cmdletName
                Add-Content -Value $proxyForScript -Path $moduleFilePath
    
                Write-ColorHost "Extraced cmdlet `"<Green>$cmdletName</Green>`" from $($_.VersionInfo.FileName)"
            }
        }
    }

    #
    # Step 2: Import module
    #
    Import-Module -Name $ModuleName -Force -WarningAction Ignore

    #
    # Step 3: profile part
    #
    if (Test-Path $psProfileScriptPath){
        Install-PsProfile -CodeId "PackagePsProfileEntrance-$packageName" -TargetScriptPath $psProfileScriptPath -Owner "package $packageName" -Comment "Entrance for the PowerShell profile for package $packageName"
        Write-ColorHost "Injected <Green>$psProfileScriptPath</Green> to PowerShell profile."
    }

    Write-ColorHost ""
}


function Add-Shortcut
{
    param 
    ( 
        [string] $TargetPath, 
        [string] $ShortcutPath 
    )
    
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $TargetPath
    $Shortcut.Save()
}