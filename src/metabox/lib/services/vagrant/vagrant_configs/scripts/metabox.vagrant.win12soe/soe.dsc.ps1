# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Running windows SOE config..."
Trace-MbEnv

Log-MbInfoMessage "Disabling Firewalls..."
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

Log-MbInfoMessage "Setting Timezone..."
tzutil.exe /s "AUS Eastern Standard Time"
Validate-MbExitCode $LASTEXITCODE "Failed to call tzutil.exe /s 'AUS Eastern Standard Time'"

Configuration Configure_WinSOE {

    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName xNetworking
    
    Node localhost
    {
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $false
            RefreshMode = "Push"
        }

        # xTimeZone TimeZone
        # {
        #     IsSingleInstance = 'Yes'
        #     TimeZone         = 'AUS Eastern Standard Time'
        # }

        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
        }

        WindowsFeature ADDSRSAT
        {
            Ensure = "Present"
            Name = "RSAT-ADDS-Tools"
        }

        WindowsFeature RSAT
        {
            Ensure = "Present"
            Name = "RSAT"
        }

        Registry WindowsUpdate_NoAutoUpdate
        {
            Ensure      = "Present"  
            Key         = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
            ValueName   = "NoAutoUpdate"
            ValueData   = 1
            ValueType = "DWord"
        }

        Registry WindowsUpdate_AUOptions
        {
            Ensure      = "Present"  
            Key         = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
            ValueName   = "AUOptions"
            ValueData   = 2
            ValueType = "DWord"
        }
       
    }
}

$config = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            RetryCount = 10           
            RetryIntervalSec = 30
        }
    )
}

Apply-MbDSC "Configure_WinSOE" $config 

exit 0