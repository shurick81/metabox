# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"
. "c:/Windows/Temp/_metabox_core.ps1"

Log-MbInfoMessage "Running DSC: SP2013_InstallBin"

$installDir = $ENV:METABOX_INSTALL_DIR
$productKey = $ENV:METABOX_SP_PRODUCT_KEY

if($installDir -eq $null) {
    throw "METABOX_INSTALL_DIR env var is null or empty"
} else {
    Log-MbInfoMessage "Using [ENV:METABOX_INSTALL_DIR]: $installDir"
}

if($productKey -eq $null) {
    Log-MbInfoMessage "Can't find productKey - [ENV:METABOX_SP_PRODUCT_KEY] is NULL. Throwing..."
    throw "Can't find productKey - [ENV:METABOX_SP_PRODUCT_KEY] is NULL. Throwing..."
} else {
    Log-MbInfoMessage "Using [ENV:METABOX_SP_PRODUCT_KEY]"
}

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