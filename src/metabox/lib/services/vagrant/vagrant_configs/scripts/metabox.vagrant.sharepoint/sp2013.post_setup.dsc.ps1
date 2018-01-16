# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

# include shared halpers from metabox.vagrant.sharepoint handler
Include-MbSharedHandlerScript "metabox.vagrant.sharepoint" "sp.helpers.ps1"

Log-MbInfoMessage "Running SharePoint post-setup tuning..."
Trace-MbEnv

Configuration Install_SharePointFarmTuning
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SharePointDsc
    Import-DscResource -ModuleName xWebAdministration
    
    Node localhost {

        LocalConfigurationManager 
        {
            RebootNodeIfNeeded = $false
        }

        Service SharePointAdministration {
            Ensure = "Present"
            Name = "SPAdminV4"
            StartupType = "Automatic"
            State = "Running"
        }

        Service SharePointSearchHostController {
            Ensure = "Present"
            Name = "SPSearchHostController"
            StartupType = "Automatic"
            State = "Running"
        }

        Service SharePointServerSearch15 {
            Ensure = "Present"
            Name = "OSearch15"
            StartupType = "Automatic"
            State = "Running"
        }

        Service SharePointTimerService {
            Ensure = "Present"
            Name = "SPTimerV4"
            StartupType = "Automatic"
            State = "Running"
        }

        Service SharePointTracingService {
            Ensure = "Present"
            Name = "SPTraceV4"
            StartupType = "Automatic"
            State = "Running"
        }

        Service SharePointUserCodeHost {
            Ensure = "Present"
            Name = "SPUserCodeV4"
            StartupType = "Automatic"
            State = "Running"
        }

        xWebsite SharePointCentralAdministrationv4 {
            Ensure = "Present"
            Name="SharePoint Central Administration v4"
            State = "Started"
        }

        xWebsite SharePointWebServices {
            Ensure = "Present"
            Name="SharePoint Web Services"
            State = "Started"
        }

        xWebAppPool SecurityTokenServiceApplicationPool { 
            Ensure = "Present"
            Name="SecurityTokenServiceApplicationPool"
            State = "Started"
        }

        xWebAppPool SharePointCentralAdministrationv4AppPool { 
            Ensure = "Present"
            Name="SharePoint Central Administration v4"
            State = "Started"
        }

        xWebAppPool SharePointWebServicesRootAppPool { 
            Ensure = "Present"
            Name="SharePoint Web Services Root"
            State = "Started"
        }

     }
}

$config = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'

            PSDscAllowDomainUser = $true
            PSDscAllowPlainTextPassword = $true

            RetryCount = 10           
            RetryIntervalSec = 30
        }
    )
}

Apply-MbDSC "Install_SharePointFarmTuning" $config 

exit 0
