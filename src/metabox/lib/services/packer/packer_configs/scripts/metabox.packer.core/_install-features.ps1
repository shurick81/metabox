# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Fixing up windows features..."
Trace-MbEnv

$installFeatures = @(
    #"Net-Framework-Features"
)

$uninstallFeatures = @(
    "Windows-Defender-GUI",
    "Windows-Defender"
)

Write-Host "Installing features: [$installFeatures]"

foreach($feature in $installFeatures) {
    Write-Host "Installing feature: [$feature]"
    Install-WindowsFeature -Name $feature
}

Write-Host "Adding features: [$addFeatures]"

foreach($feature in $addFeatures) {
    Write-Host "Installing feature: [$feature]"
    Add-WindowsFeature -Name $feature
}

Write-Host "Uninstalling features: [$uninstallFeatures]"

foreach($feature in $uninstallFeatures) {
    
    Write-Host "Checking if feature: [$feature] exists"
    
    if( (Get-WindowsFeature -Name $feature -ErrorAction SilentlyContinue) -ne $null)
    {
        Write-Host "Uninstalling [$feature] features..."
        Uninstall-WindowsFeature -Name $feature
    } 
    else {
        Write-Host "Didn't detect [$feature]. No uninstall is required. Skipping."
    }
}