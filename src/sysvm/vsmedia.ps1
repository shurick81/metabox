$configName = "VSMedia"
Configuration $configName
{
    param(
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -Name xRemoteFile -ModuleVersion 8.0.0.0
    
    Node $AllNodes.NodeName
    {

        File TempDir {
            DestinationPath = "C:\Temp\MB"
            Type = "Directory"
        }

        xRemoteFile VSInstallerDownload
        {
            Uri             = "https://download.visualstudio.microsoft.com/download/pr/11346816/52257ee3e96d6e07313e41ad155b155a/vs_Enterprise.exe"
            DestinationPath = "C:\Temp\MB\vs_Enterprise.exe"
            DependsOn       = "[File]TempDir"
        }
        
        File LayoutDirectory {
            DestinationPath = "D:\MBFileResources\VS2017"
            Type = "Directory"
        }
        
        $securePassword = ConvertTo-SecureString "vagrant" -AsPlainText -Force
        $adminCreds = New-Object System.Management.Automation.PSCredential( "vagrant", $securePassword )

        Script VSLayer
        {
            SetScript = {
                Start-Process -FilePath C:\Temp\MB\vs_Enterprise.exe -ArgumentList '--layout D:\MBFileResources\VS2017 --add Microsoft.VisualStudio.Workload.Office --includeRecommended --lang en-US --quiet' -Wait;
            }
            TestScript = {
                Get-Item D:\MBFileResources\VS2017 | % { return $true }
                return $false
            }
            GetScript = {
                Get-Item D:\MBFileResources\VS2017 | % { return "true" }
                return "false"
            }
            DependsOn = @( "[xRemoteFile]VSInstallerDownload", "[File]LayoutDirectory")
            PsDscRunAsCredential     = $adminCreds
        }
        
    }
}

$configurationData = @{ AllNodes = @(
    @{ NodeName = 'localhost'; PSDscAllowPlainTextPassword = $True; PsDscAllowDomainUser = $True }
) }

&$configName `
    -ConfigurationData $configurationData;
Start-DscConfiguration $configName -Verbose -Wait -Force;