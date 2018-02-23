# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Installing PowerShell Modules..."
Trace-MbEnv

$packages = @(
    @{ Id = "PSWindowsUpdate";      Version = "2.0.0.0" },
    @{ Id = "Pester";               Version = "4.3.1" },

    @{ Id = "cChoco";               Version = "2.3.1.0" },
    @{ Id = "cFirewall";            Version = "1.0.1" },

    @{ Id = "SharePointDSC";        Version = "1.9.0.0" },
    @{ Id = "MS_xVisualStudio";     Version = "1.0.0.0" },

    @{ Id = "xActiveDirectory";     Version = "2.17.0.0" },
    @{ Id = "xSQLServer";           Version = "9.1.0.0" },
    @{ Id = "xDSCFirewall";         Version = "1.6.21" },
    @{ Id = "xNetworking";          Version = "5.5.0.0" },`
    @{ Id = "xTimeZone";            Version = "1.7.0.0" },
    @{ Id = "xWebAdministration";   Version = "1.19.0.0" },
    @{ Id = "xPendingReboot";       Version = "0.3.0.0" },
    @{ Id = "xComputerManagement";  Version = "4.0.0.0" },

    @{ Id = "DSCR_Shortcut";        Version = "1.3.1" }
)

Log-MbInfoMessage "Installing DSC modules: $packages"
Install-MbPSModules $packages

exit 0