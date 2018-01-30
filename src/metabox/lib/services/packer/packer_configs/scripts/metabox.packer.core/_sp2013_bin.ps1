
# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Running SharePoint prerequisiteinstaller..."
Trace-MbEnv

$installDir = Get-MbEnvVariable "METABOX_INSTALL_DIR"
$productKey = Get-MbEnvVariable "METABOX_SP_PRODUCT_KEY"

Configuration SP2013_InstallBin
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SharePointDsc

    node "localhost"
    {        
        SPInstall InstallSharePoint {
            Ensure = "Present"
            BinaryDir = $Node.InstallDir
            ProductKey = $Node.ProductKey 
        }
    }
}

$config = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            
            PSDscAllowDomainUser        = $true
            PSDscAllowPlainTextPassword = $true
            
            RetryCount = 10           
            RetryIntervalSec = 30

            InstallDir = $installDir
            ProductKey = $productKey
        }
    )
}

Apply-MbDSC "SP2013_InstallBin" $config 

exit 0