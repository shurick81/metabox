# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Installing Chocolatey packages..."
Trace-MbEnv

$packages = @(
    @{ Id = "7zip"; Version = "" },
    @{ Id = "ruby"; Version = "2.4.2.2" }
)

Log-MbInfoMessage "Installing packages: $packages"

foreach($package in $packages ) {

    Log-MbInfoMessage "`tinstalling package: $($package.Id) $($package.Version)"
    
    if ([System.String]::IsNullOrEmpty($package["Version"]) -eq $true) {
        choco install -y $package["Id"];
    } else {
        choco install -y $package["Id"] --version $package["Version"]
    }

    Validate-MbExitCode $LASTEXITCODE "Cannot install package: $package"
}

exit 0