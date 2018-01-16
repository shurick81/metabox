# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"
. "c:/Windows/Temp/_metabox_core.ps1"

Log-MbInfoMessage  "Updating package provider..."
$p = Get-PackageProvider -ListAvailable

Log-MbInfoMessage "Available providers: $p"

if( ($p | Where-Object { $_.Name.Contains("NuGet") -eq $true } ) -eq $null)
{
    Log-MbInfoMessage "Installing Nuget Package provider..."
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
   
    Log-MbInfoMessage "Updating PSGallery as Trusted"
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
} 
else 
{
    Log-MbInfoMessage "No update required."
}