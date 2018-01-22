
# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Running SharePoint prerequisiteinstaller..."
Trace-MbEnv

$installDir = Get-MbEnvVariable "METABOX_INSTALL_DIR"

Log-MbInfoMessage "Checking if prerequisiteinstaller is still running..."
Wait-MbProcess "prerequisiteinstaller"

Configuration SP2013_InstallPrereqs
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SharePointDsc

    node "localhost"
    {        
        SPInstallPrereqs InstallPrereqs {
            Ensure            = "Present"
            InstallerPath     = ($Node.InstallDir + "\prerequisiteinstaller.exe")
            OnlineMode        = $true
        }

        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $False
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

            InstallDir = $installDir
        }
    )
}

Apply-MbDSC "SP2013_InstallPrereqs" $config 

exit 0