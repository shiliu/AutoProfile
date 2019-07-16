try { Set-EnvVar -Name "SynologyDriveRoot" -Value $(Get-SynologyDriveRoot) -Target User } catch {}
try { Set-EnvVar -Name "OneDriveRoot" -Value $(Get-OneDriveRoot) -Target User } catch {}
try { Set-EnvVar -Name "OneDriveMicrosoftRoot" -Value $(Get-OneDriveRoot Microsoft) -Target User } catch {}