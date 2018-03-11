$configName = "FileShare"
Configuration $configName
{
    param(
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xSmbShare -ModuleVersion 2.0.0.0
    
    Node $AllNodes.NodeName
    {

        File FileShareDirectory
        {
            DestinationPath = "D:\MBFileResources"
            Type            = "Directory"
        }

        xSmbShare FileShare
        {
            Ensure      = "Present" 
            Name        = "MBFileResources"
            Path        = "D:\MBFileResources"
            FullAccess  = "vagrant"
            Description = "File Share for saving MB fire resources"
            DependsOn   = "[File]FileShareDirectory"
        }

    }
}

$configurationData = @{ AllNodes = @(
    @{ NodeName = 'localhost'; PSDscAllowPlainTextPassword = $True; PsDscAllowDomainUser = $True }
) }

&$configName `
    -ConfigurationData $configurationData;
Start-DscConfiguration $configName -Verbose -Wait -Force;
