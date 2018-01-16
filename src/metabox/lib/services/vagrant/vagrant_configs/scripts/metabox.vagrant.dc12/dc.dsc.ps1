# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Installing new domain controller..."
Trace-MbEnv

$domainName =           Get-MbEnvVariable "METABOX_DC_DOMAIN_NAME"
$domainAdminName =      Get-MbEnvVariable "METABOX_DC_DOMAIN_ADMIN_NAME"
$domainAdminPassword =  Get-MbEnvVariable "METABOX_DC_DOMAIN_ADMIN_PASSWORD"

function Configure-DCPromo($domainAdminPass) {
    # https://aryannava.com/2012/01/05/administrator-password-required-error-in-dcpromo-exe/

    $message =  "Executing 'net user Administrator /passwordreq:yes' to bypass dcpromo errors"
    Log-MbInfoMessage $message 
    
    net user Administrator $domainAdminPass /passwordreq:yes
    Validate-MbExitCode $LASTEXITCODE "Failed to execute: $message"
}

Configure-DCPromo $domainAdminPassword

Configuration Install_DomainController {

    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName xNetworking
    
    Node localhost
    {
        $domainName = $Node.DomainName
        $domainAdminName = $Node.DomainAdminName
        $domainAdminPassword = $Node.DomainAdminPassword

        $securePassword = ConvertTo-SecureString $domainAdminPassword -AsPlainText -Force
        
        $domainAdminCreds = New-Object System.Management.Automation.PSCredential($domainAdminName, $securePassword)
        $safeModeAdminCreds = $domainAdminCreds

        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $false
            RefreshMode = "Push"
        }

        WindowsFeature DNS
        {
            Ensure = "Present"
            Name   = "DNS"
        }

        xDnsServerAddress DnsServerAddress
        {
            Address        = '127.0.0.1'
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPv4'
            DependsOn      = "[WindowsFeature]DNS"
        }

        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name   = "AD-Domain-Services"
        }

        WindowsFeature ADDSRSAT
        {
            Ensure = "Present"
            Name   = "RSAT-ADDS-Tools"
        }

        WindowsFeature RSAT
        {
            Ensure = "Present"
            Name   = "RSAT"
        }

        xADDomain PrimaryDomainController
        {
            DomainName = $domainName
            # win16 fix
            # http://vcloud-lab.com/entries/active-directory/powershell-dsc-xactivedirectory-error-a-netbios-domain-name-must-be-specified-
            DomainNetBIOSName = $domainName.Split('.')[0]
            
            DomainAdministratorCredential = $domainAdminCreds
            SafemodeAdministratorPassword = $safeModeAdminCreds
            
            DatabasePath = "C:\NTDS"
            LogPath      = "C:\NTDS"
            SysvolPath   = "C:\SYSVOL"
            
            DependsOn = @(
                "[WindowsFeature]ADDSInstall", 
                "[WindowsFeature]RSAT", 
                "[WindowsFeature]ADDSRSAT", 
                "[xDnsServerAddress]DnsServerAddress"
            )
        }
    }
}

$config = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'

            PSDscAllowDomainUser        = $true
            PSDscAllowPlainTextPassword = $true
            
            RetryCount       = 10           
            RetryIntervalSec = 30

            DomainName           = $domainName
            DomainAdminName      = $domainAdminName
            DomainAdminPassword  = $domainAdminPassword
        }
    )
}

Apply-MbDSC "Install_DomainController" $config 

exit 0
