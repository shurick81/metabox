# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Installing PowerShell Modules..."
Trace-MbEnv

$packages = @(
    @{ Id = "PSWindowsUpdate"; Version = "" },
    @{ Id = "Pester"; Version = "" },

    @{ Id = "cChoco"; Version = "" },
    @{ Id = "cFirewall"; Version = "" },

    @{ Id = "SharePointDSC"; Version = "" },
    @{ Id = "MS_xVisualStudio"; Version = "" },

    @{ Id = "xActiveDirectory"; Version = "" },
    @{ Id = "xSQLServer"; Version = "" },
    @{ Id = "xDSCFirewall"; Version = "" },
    @{ Id = "xNetworking"; Version = "" },`
    @{ Id = "xTimeZone"; Version = "" },
    @{ Id = "xWebAdministration"; Version = "" },
    @{ Id = "xPendingReboot"; Version = "" },
    @{ Id = "xComputerManagement"; Version = "" }
)

Log-MbInfoMessage "Installing DSC modules: $packages"

foreach($package in $packages ) {

    Log-MbInfoMessage "`tinstalling package: $($package.Id) $($package.Version)"
    
    if ([System.String]::IsNullOrEmpty($package["Version"]) -eq $true) {
        Install-Module -Name $package["Id"] -Force;
    } else {
        Install-Module -Name $package["Id"] -RequiredVersion $package["Version"] -Force;
    }
}

exit 0