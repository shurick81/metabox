# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Installing Visual Studio..."
Trace-MbEnv

$execPath = Get-MbEnvVariable "METABOX_VS_EXECUTABLE_PATH"
$productName = Get-MbEnvVariable "METABOX_VS_PRODUCT_NAME"
$deploymentFilePath = Get-MbEnvVariable "METABOX_VS_ADMIN_DEPLOYMENT_FILE_PATH"

$domainUserName = Get-MbEnvVariable "METABOX_VS_DOMAIN_USER_NAME"
$domainUserPassword = Get-MbEnvVariable "METABOX_VS_DOMAIN_USER_PASSWORD"

# check if $execPath exists
# the reason is that different VS editions have different EXE files:
# - vs_ultimate.exe
# - vs_enterprise.exe
# if not, them look for .exe file at the top folder in $execPath
$execPath = Find-MbFileInPath $execPath
Log-MbInfoMessage "Using VS install file: $execPath"

Configuration Install_VS2013 {

    Import-DSCResource -Name MS_xVisualStudio  

    Node localhost {

        $securePassword = ConvertTo-SecureString $Node.DomainUserPassword -AsPlainText -Force
        $domainUserCreds = New-Object System.Management.Automation.PSCredential($Node.DomainUserName, $securePassword)

        MS_xVisualStudio VistualStudio
        {
            Ensure = "Present"    
            PsDscRunAsCredential = $domainUserCreds

            ExecutablePath = $Node.ExecutablePath 
            ProductName =  $Node.ProductName  
            AdminDeploymentFile =  $Node.AdminDeploymentFile  
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

            DomainUserName = $domainUserName
            DomainUserPassword = $domainUserPassword

            ExecutablePath = $execPath
            ProductName = $productName
            AdminDeploymentFile = $deploymentFilePath
        }
    )
}

Apply-MbDSC "Install_VS2013" $config 

exit 0