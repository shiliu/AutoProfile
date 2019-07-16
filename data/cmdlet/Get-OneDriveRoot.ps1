# References:
# 1. Below are the list of predefined vars that can be used:
#    - $PSScriptRoot		[System defined] The folder path for current scipt file, NOT the caller script to call this function

Param 
(
	[Parameter(Mandatory=$false, Position=0)]
	[string] $BusinessName = ""
)

$isForOneDriveBusiness = (-not [string]::IsNullOrWhiteSpace($BusinessName))
if ($isForOneDriveBusiness) {
	$titleCaseBusinessName = (Get-Culture).TextInfo.ToTitleCase($BusinessName.Trim())
	$titleCaseBusinessNameWithoutSpace = $titleCaseBusinessName.Replace(" ", "")
	$oneDriveEnvVarName = "OneDrive$($titleCaseBusinessNameWithoutSpace)Root"
	$oneDriveFolderName = "OneDrive - $titleCaseBusinessName"
}
else {
	$oneDriveEnvVarName = "OneDriveRoot"
	$oneDriveFolderName = "OneDrive"
}

# Step 1: Try to get from our own ENV variable
$ret = [Environment]::GetEnvironmentVariable($oneDriveEnvVarName)
if (-not [string]::IsNullOrWhiteSpace($ret)){
	if (Test-Path $ret){ return $ret }
}

# Step 2: Try to get from System/Microsoft registered OneDrive ENV variable
$ret = if ($isForOneDriveBusiness) { $ENV:OneDriveCommercial } else { $ENV:OneDriveConsumer }
if (-not [string]::IsNullOrWhiteSpace($ret)){
	if (Test-Path $ret){
		[Environment]::SetEnvironmentVariable($oneDriveEnvVarName, $ret, [EnvironmentVariableTarget]::User)
		return $ret 
	}
}

# Step 3: Try to find the OneDrive folder from user profile and other possible locations.
$possibleParentFolders = @("$env:USERPROFILE") -join ";"
$possibleOneDriveFolderNames = @($oneDriveFolderName) -join ";"

$ret = Get-FirstExistedPath -PathPart1 $possibleParentFolders -PathPart2 $possibleOneDriveFolderNames
if (-not [string]::IsNullOrWhiteSpace($ret)){
	if (Test-Path $ret){
		[Environment]::SetEnvironmentVariable($oneDriveEnvVarName, $ret, [EnvironmentVariableTarget]::User)
		return $ret 
	}
}

return $ret