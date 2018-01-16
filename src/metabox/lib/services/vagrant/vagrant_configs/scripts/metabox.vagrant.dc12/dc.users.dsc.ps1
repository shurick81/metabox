# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Installing new domain controller..."
Trace-MbEnv

function WaitForAdServices($tries) {
    
    # Somehow Win2016 might stuck at "Applying computer settings"
    # that happens for several minutes, them all comes back
    # could be a feature setup after DC/Defender removal, could be DNS thing

    # so waiting for 5 minutes, and then fail
    $user = "vagrant"  

    # 10 sec timout
    $timeOut = 10000

    # 10 minutes (6 * 10 sec => 10 times)
    if($tries -eq $null) {
        $tries = 6 * 10
    }

    $current = 0;
    $hasError = $false

    do {

        try {
            Log-MbInfoMessage "[$current/$tries] Trying to resolve user: [$user]"
            $user = Get-ADUser "vagrant"  
            
            $hasError = $false

            Log-MbInfoMessage "[$current/$tries] No error! Nice!"
        } catch {

            Log-MbInfoMessage "Failed with $_"
            Log-MbInfoMessage "Sleeping [$timeOut] milliseconds..."

            $current++;
            Start-Sleep -Milliseconds $timeOut
            $hasError = $true
        }

        if($hasError -eq $false) {
            break;
        }

        if($current -gt $tries) {
            break;
        }
    }
    while($hasError -eq $true)
}

$domainName =           Get-MbEnvVariable "METABOX_DC_DOMAIN_NAME"
$vagrantUserName =      Get-MbEnvVariable "METABOX_VAGRANT_USER_NAME"
$vagrantUserPassword =  Get-MbEnvVariable "METABOX_VAGRANT_USER_PASSWORD"
$domainUserName =       Get-MbEnvVariable "METABOX_DC_DOMAIN_ADMIN_NAME"
$domainUserPassword =   Get-MbEnvVariable "METABOX_DC_DOMAIN_ADMIN_PASSWORD"

# ensuring AD services are up and running
Log-MbInfoMessage "Starting NTDS service..."
start-service NTDS 

Log-MbInfoMessage "Starting ADWS service..."
start-service ADWS 

# wait until AD comes up after reboot and applying setting
Log-MbInfoMessage "Waiting for host to apply setting and make AD available...";
WaitForAdServices

$securePassword = ConvertTo-SecureString $domainUserPassword -AsPlainText -Force

$domainAdminCreds = New-Object System.Management.Automation.PSCredential($domainUserName, $securePassword)
$safeModeAdminCreds = $domainAdminCreds

$vagrantSecurePassword = ConvertTo-SecureString $vagrantUserPassword -AsPlainText -Force
$vagrantCreds = New-Object System.Management.Automation.PSCredential($vagrantUserName, $vagrantSecurePassword)

Configuration Configure_DomainUsers {

    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName xNetworking
    
    Node localhost
    {
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $false
            RefreshMode = "Push"
        }

        xADUser DomainAdmin
        {
            DomainName = $Node.DomainName 
            DomainAdministratorCredential = $vagrantCreds 
            UserName = $domainUserName
            Password = $domainAdminCreds
            Ensure = "Present"
        }

        # this might fail, really unstable
        # reverting back to Add-ADGroupMember calls

        # xADGroup DomainAdmins {
        #    GroupName = 'Domain Admins'
        #    MembersToInclude = @('meta\vagrant','meta\admin')
        #    DependsOn = "[xADUser]DomainAdmin"
        #    #DomainController = $env:ComputerName
        # }

        # Group DomainAdmins {
        #    GroupName = 'Domain Admins'
        #    #DomainController = "meta"
        #    MembersToInclude = @('meta\admin')
        #    DependsOn = "[xADUser]DomainAdmin"
        #    #DomainController = $env:ComputerName
        # }
    }
}

$config = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
            RetryCount = 10           
            RetryIntervalSec = 30

            DomainName = $domainName.Split('.')[0]
        }
    )
}

Apply-MbDSC "Configure_DomainUsers" $config 

# ensuring group memebership
Log-MbInfoMessage "Ensuring group memberships..."
Add-ADGroupMember 'Domain Admins' 'vagrant',' admin'

exit 0