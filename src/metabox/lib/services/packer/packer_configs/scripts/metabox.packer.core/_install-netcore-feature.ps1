# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Installing NET-Framework-Core feature..."
Trace-MbEnv

Configuration NETFrameworkCore
{
    Node localhost {

        LocalConfigurationManager 
        {
            RebootNodeIfNeeded = $false
        }

        Registry UpdateFromWindowsUpdateCenterEnable
        {
            Ensure      = "Present"
            Key         = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Servicing"
            ValueName   = "LocalSourcePath"
            ValueType   = "ExpandString"
        }

        Registry UpdateFromWindowsUpdateCenter
        {
            Ensure      = "Present"
            Key         = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Servicing"
            ValueName   = "RepairContentServerSource"
            ValueType   = "DWORD"
            ValueData   = "2"
            DependsOn   = "[Registry]UpdateFromWindowsUpdateCenterEnable"
        }

        WindowsFeature "NET-Framework-Core" 
        {
            Ensure  = "Present"
            Name    = "NET-Framework-Core"
            Source  = "Windows Update"
        }
    }
}

Log-MbInfoMessage "Installing feature: NET-Framework-Core"
Apply-MbDSC "NETFrameworkCore"

exit 0