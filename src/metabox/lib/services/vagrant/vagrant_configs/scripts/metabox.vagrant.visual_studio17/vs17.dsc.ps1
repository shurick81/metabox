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

Configuration Install_VS2017 {

    Node localhost {

        $securePassword = ConvertTo-SecureString "vagrant" -AsPlainText -Force
        $domainUserCreds = New-Object System.Management.Automation.PSCredential( "vagrant", $securePassword )

        File VSLocalMedia {
            SourcePath = "\\192.168.52.252\MBFileResources\VS2017"
            DestinationPath = "C:\VS2017"
            Recurse = $true
            Type = "Directory"
            Credential = $domainUserCreds
        }

        Script VSInstallerRun
        {
            SetScript = {
                Start-Process -FilePath C:\VS2017\vs_enterprise.exe -ArgumentList '--quiet --wait --add Microsoft.VisualStudio.Workload.Office --includeRecommended' -Wait;
            }
            TestScript = {
                Get-WmiObject -Class Win32_Product | ? { $_.name -eq "Microsoft Visual Studio Setup Configuration" } | % { return $true }
                return $false
            }
            GetScript = {
                $installedApplications = Get-WmiObject -Class Win32_Product | ? { $_.name -eq "Microsoft Visual Studio Setup Configuration" }
                return @{ Result = $installedApplications }
            }
            DependsOn = @( "[File]VSLocalMedia" )
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

Apply-MbDSC "Install_VS2017" $config 

exit 0