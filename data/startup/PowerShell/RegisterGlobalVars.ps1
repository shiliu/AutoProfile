try { Set-EnvVar -Name "BranchUtahRoot" -Value $(Get-BranchRoot Utah) -Target User } catch {}
try { Set-EnvVar -Name "BranchSubstrateRoot" -Value $(Get-BranchRoot Substrate) -Target User } catch {}
try { Set-EnvVar -Name "BranchControlPlaneRoot" -Value $(Get-BranchRoot ControlPlane) -Target User } catch {}