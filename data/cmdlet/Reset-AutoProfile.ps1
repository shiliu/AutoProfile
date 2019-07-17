<#
.SYNOPSIS
Reset all for Auto Profile to apply latest changes.

.DESCRIPTION

.EXAMPLE

#>

# References:
# 1. Below are the list of predefined vars that can be used:
#    - $PSScriptRoot		[System defined] The folder path for current scipt file, NOT the caller script to call this function

# Clean up

# Invoke OS profile
. "$PSScriptRoot\..\OsProfile.ps1"

# Invoke Ps Profile
. "$PSScriptRoot\..\PsProfile.ps1"