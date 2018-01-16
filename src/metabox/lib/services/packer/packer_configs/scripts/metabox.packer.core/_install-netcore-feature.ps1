
# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"
. "c:/Windows/Temp/_metabox_core.ps1"

Configuration NETFrameworkCore
{
    Node localhost {

        LocalConfigurationManager 
        {
            RebootNodeIfNeeded = $false
        }

        WindowsFeature "NET-Framework-Core" 
        {
            Ensure="Present"
            Name = "NET-Framework-Core"
        }
    }
}

Log-MbInfoMessage "Installing feature: NET-Framework-Core"
Apply-MbDSC "NETFrameworkCore"

exit 0