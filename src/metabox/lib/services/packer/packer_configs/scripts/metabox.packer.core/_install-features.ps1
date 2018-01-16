
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