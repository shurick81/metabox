param (
    [string]$DomainName = "meta.local",
    [string]$DomainUserName = "admin",
    [string]$DomainUserPassword = "u8wxvKQ2zn"
)

# trace
Write-Host "Running SharePoint post-setup tuning..."

Configuration SPFarmTuning
{
    $DomainUserName = "meta\vagrant"
    $DomainUserPassword = "vagrant"

    $passPhrase = "u8wxvKQ2zn"

    $secpasswd = ConvertTo-SecureString $DomainUserPassword -AsPlainText -Force
    $DomainCreds = New-Object System.Management.Automation.PSCredential($DomainUserName, $secpasswd)
    
    $secPassPhrase = ConvertTo-SecureString $passPhrase -AsPlainText -Force
    $PassPhraseCreds = New-Object System.Management.Automation.PSCredential($DomainUserName, $secPassPhrase)
    

    $SPSetupAccount = $DomainCreds
    $Passphrase = $PassPhraseCreds
    $FarmAccount = $DomainCreds

    $ServicePoolManagedAccount = $DomainCreds
    $WebPoolManagedAccount = $DomainCreds

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

$cd = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'

            PSDscAllowDomainUser = $true
            PSDscAllowPlainTextPassword = $true

            DomainUserName = $domainUserName
            DomainUserPassword = $domainUserPassword

            RetryCount = 10           
            RetryIntervalSec = 30
        }
    )
}


if(Test-Path SPFarmTuning)
{
    Remove-Item SPFarmTuning -Recurse -Force
}

SPFarmTuning -ConfigurationData $cd;
Start-DscConfiguration SPFarmTuning -Force -Wait -Verbose 
