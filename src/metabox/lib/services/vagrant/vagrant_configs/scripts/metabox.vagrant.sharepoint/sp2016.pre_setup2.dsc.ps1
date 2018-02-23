# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

# include shared halpers from metabox.vagrant.sharepoint handler
Include-MbSharedHandlerScript "metabox.vagrant.sharepoint" "sp.helpers.ps1"

Log-MbInfoMessage "Running SharePoint pre-setup2 tuning..."
Trace-MbEnv

Log-MbInfoMessage "Running: Install-WindowsFeature Web-Server -IncludeAllSubFeature"
Install-WindowsFeature Web-Server -IncludeAllSubFeature

# Missed NET-WCF-HTTP-Activation45 in SharePoint 2016 images #55
# https://github.com/SubPointSolutions/metabox/issues/55
Log-MbInfoMessage "Running: Install-WindowsFeature NET-WCF-HTTP-Activation45"
Install-WindowsFeature NET-WCF-HTTP-Activation45

Configuration Install_SharePointFarmPreSetupTuning
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SharePointDsc
    Import-DscResource -ModuleName xWebAdministration
    
    Node localhost {

        LocalConfigurationManager 
        {
            RebootNodeIfNeeded = $false
        }

        # ensuring that required services are up before running SharePoint farm creation
        Service W3SVC
        {
            Name            = "W3SVC"
            StartupType     = "Automatic"
            State           = "Running"
        }  

        Service IISADMIN
        {
            DependsOn       = "[Service]W3SVC"

            Name            = "IISADMIN"
            StartupType     = "Automatic"
            State           = "Running"
        }  

        WindowsFeature NETWCFHTTPActivation45
        {
            Ensure = "Present"
            Name   = "NET-WCF-HTTP-Activation45"
        }
     }
}

$config = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'

            PSDscAllowDomainUser = $true
            PSDscAllowPlainTextPassword = $true
        }
    )
}

Apply-MbDSC "Install_SharePointFarmPreSetupTuning" $config 

# ensuring other services are up
Safe-MbIISReset

exit 0