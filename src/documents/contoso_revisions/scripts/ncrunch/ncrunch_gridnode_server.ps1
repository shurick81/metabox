# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Running NCrunch Grid Node Server configuration..."
Trace-MbEnv

$packageVersion  = Get-MbEnvVariable "NCRUNCH_GRIDNODE_VERSION"

Configuration Install_NCrunchGridNodeServer
{
    Import-DscResource -Module CChoco
   
    Node localhost
    { 
        cChocoPackageInstaller NCrunchGrid
        {
            Name                 = 'ncrunch-gridnodeserver'
            Ensure               = 'Present'
            AutoUpgrade          = $false
            Version              = $Node.PackageVersion
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

            PackageVersion  = $packageVersion
        }
    )
}

Apply-MbDSC "Install_NCrunchGridNodeServer" $config 

exit 0