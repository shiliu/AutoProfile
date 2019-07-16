# IMPORTANT: Before releasing this package, copy/paste the next 2 lines into PowerShell to remove all comments from this file:
#   $f='c:\path\to\thisFile.ps1'
#   gc $f | ? {$_ -notmatch "^\s*#"} | % {$_ -replace '(^.*?)\s*?[^``]#.*','$1'} | Out-File $f+".~" -en utf8; mv -fo $f+".~" $f

# 1. See the _TODO.md that is generated top level and read through that
# 2. Follow the documentation below to learn how to create a package for the package type you are creating.
# 3. In Chocolatey scripts, ALWAYS use absolute paths - $toolsDir gets you to the package's tools directory.
$ErrorActionPreference = 'Stop'; # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# Import the helper functions
. "$toolsDir\ChocoHelperLib.ps1"

# Disable strong name validation
reg DELETE HKLM\Software\Microsoft\StrongName\Verification /f
reg ADD HKLM\Software\Microsoft\StrongName\Verification\*,* /f
reg DELETE HKLM\Software\Wow6432Node\Microsoft\StrongName\Verification /f
reg ADD HKLM\Software\Wow6432Node\Microsoft\StrongName\Verification\*,* /f

# Install Toolkit
Install-PsPackage -PackageRoot $($Env:ChocolateyPackageFolder)

# Register startup scripts path & init system
$psStartupPath = Join-Path $toolsDir "..\data\startup\PowerShell" -Resolve
Add-PathToEnvVar -Path $psStartupPath -EnvVarName "StartupScriptsPaths" -Container Machine
try{ Init-System } catch {}