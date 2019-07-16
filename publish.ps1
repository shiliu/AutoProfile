$curScriptFolder  = $PSScriptRoot
cd $curScriptFolder

# Make sure ChocoHelperLib.ps1 is up to date
$curHelperLibPath = Join-Path $curScriptFolder "tools\ChocoHelperLib.ps1"
$latestHelperLibPath = Join-Path $curScriptFolder "..\..\HelperScripts\ChocoHelperLib.ps1" -Resolve
if ((Test-Path $curHelperLibPath) -and (Test-Path $latestHelperLibPath)){ Copy-Item $latestHelperLibPath $curHelperLibPath -Force }

# Update the package version #
$nuspecFileName = (Get-ChildItem -Path $curScriptFolder -Filter "*.nuspec" | select -First 1).Name
$nuspecFilePath = Join-Path $curScriptFolder $nuspecFileName
if (Test-Path $nuspecFilePath)
{
    $nuspecContent = Get-Content -Raw -Path $nuspecFilePath
    $curVersionMatch = [Regex]::Match($nuspecContent, '<version>(\d+.\d+.\d+.\d+)<\/version>', 1)
    if ($curVersionMatch.Success)
    {
        $curVersionSectionStr = $curVersionMatch.Value
        $curVersionStr = $curVersionMatch.Groups[1].Value
        $curVersion = [Version]($curVersionStr)
    
        $defaultNewVersionStr = "$($curVersion.Major).$($curVersion.Minor).$($curVersion.Build).$($curVersion.Revision + 1)"

        Write-ColorHost ""
        Write-ColorHost "The current defined version is <Yellow>$curVersionStr</Yellow>. And the default new version is <Yellow>$defaultNewVersionStr</Yellow>"

        $newVersionStr = ""
        do {
            $inputedNewVersionStr = Read-Host "Please input a new version (Press `"Enter`" to use default)"

            if ([string]::IsNullOrWhiteSpace($inputedNewVersionStr)) {
                $newVersionStr = $defaultNewVersionStr
            }
            else {
                if ([Regex]::IsMatch($inputedNewVersionStr, '\d+.\d+.\d+.\d+', 1)) {
                    $newVersionStr = $inputedNewVersionStr
                }
                else {
                    Write-ColorHost "`"<Yellow>$inputedNewVersionStr</Yellow>`" is not a valid version number, please try again."
                }
            }
        } while ([string]::IsNullOrWhiteSpace($newVersionStr))

        $newVersionSectionStr = $curVersionSectionStr -replace "$curVersionStr","$newVersionStr"
        $nuspecContent -replace "$curVersionSectionStr","$newVersionSectionStr" | Set-Content $nuspecFilePath

        Write-ColorHost "<Yellow>Update the version from $curVersionStr to <Green>$newVersionStr</Green></Yellow>"
        Write-ColorHost
    }
}

# Remove all existed package files
Remove-Item -Path "$curScriptFolder\*" -Filter "*.nupkg" -Force

# Pack the package
choco pack

# Push the package to http://choco.ddrr.org/api/odata
if ((Get-ChildItem -Path $curScriptFolder -Filter "*.nupkg").Count -eq 1){
    choco push --source='http://choco.ddrr.org/api/odata' --api-key=f81f900f-3cd4-418f-9ac7-d730cfcb5627 --force
}
else {
    throw "There is something wrong to create the package, cannot push to repository."
}

Write-Host ""
Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');