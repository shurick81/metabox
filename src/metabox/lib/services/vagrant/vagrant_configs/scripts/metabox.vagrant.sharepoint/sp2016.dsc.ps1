param (
    [string]$sqlServerName,
    [string]$spDbPrefix,

    [string]$domainUserName = "meta\vagrant",
    [string]$domainUserPassword = "vagrant",

    [string]$passPhrase = "u8wxvKQ2zn"
)

Write-Host "Creating a new SharePoint farm"
Write-Host "`tSQL Server:[$sqlServerName]"
Write-Host "`tSP Db Prefix:[$spDbPrefix]"

Write-Host "`tdomainUserName:[$domainUserName]"
Write-Host "`tdomainUserPassword:[$domainUserPassword]"
Write-Host "`tSpassPhrase:[$passPhrase]"

Write-Host "Running as:[$($env:UserDomain)\$($env:UserName)]"

Write-Host "Cleaning up SQL dbs with prefix:[$spDbPrefix]"

function Cleanup-IIS {
    Get-WebSite -Name "Default Web Site" | Remove-WebSite -Confirm:$false -Verbose
    Remove-WebAppPool -Name "DefaultAppPool" -Confirm:$false -Verbose -ErrorAction SilentlyContinue
}

function Get-ConfigDbDNS($majorVersion) {
    
    if($majorVersion -eq $null) {
        $majorVersion = "15"
    }

    $regPath = "HKLM:\SOFTWARE\Microsoft\Shared Tools\Web Server Extensions\$majorVersion.0\Secure\ConfigDB"
    $item = Get-ItemProperty  $regPath -ErrorAction SilentlyContinue

    if($item -eq $null) {
        return $null
    }

    return $item.dsn
}
    
function Exec-SqlQuery($server, $query) {
    Write-Host "Annoying SQL server [$server] with query [$query]"

    $connection = New-Object "System.Data.SqlClient.SqlConnection" `
                -ArgumentList  @("Server = $server; Database = master; Integrated Security = True;")


    $connection.Open()
    
    $sqlCommand = New-Object "System.Data.SqlClient.SqlCommand" -ArgumentList @($query, $connection);
    $reader = $sqlCommand.ExecuteNonQuery()
    $connection.Close()
}

function Exec-SqlReaderQuery($server, $query) {
    Write-Host "Annoying SQL server [$server] with query [$query]"

    $result = @()

    $connection = New-Object "System.Data.SqlClient.SqlConnection" `
                -ArgumentList  @("Server = $server; Database = master; Integrated Security = True;")


    #$sqlCommandText = $query;
    $connection.Open()
    
    $sqlCommand = New-Object "System.Data.SqlClient.SqlCommand" -ArgumentList @($query, $connection);
    $reader = $sqlCommand.ExecuteReader()

    while( $reader.Read() -eq $true) {
        $result += $reader.GetValue(0)
        #Write-Host "Result: [$($reader.GetValue(0))]"
    }

    $connection.Close()

    return $result
}

function Delete-SqlDb($name) {
    $sqlCommandText = "DROP DATABASE $name";
    $sqlCommand = New-Object System.DateSqlCommand -arguments ($sqlCommandText, $connection);
    $sqlCommand.ExecuteNonQuery();
}

[System.Reflection.Assembly]::LoadWithPartialName("System.Data")

Write-Host "Cleaning up default IIS web site..."
Cleanup-IIS

$configDbDns = Get-ConfigDbDNS 15

if($configDbDns -eq $null )
{
    $configDbDns = Get-ConfigDbDNS 16
}

Write-Host "Detected config Db DNS:[$configDbDns]"

$isSharePointInstalled = ($configDbDns -ne $null)

Write-Host "Detected isSharePointInstalled:[$isSharePointInstalled]"

if($isSharePointInstalled) {
    Write-Host "Detected that SharePoint is already installed. No need to create Farm or Join to farm"
} else {

    Write-Host "Detected that SharePoint is NOT installed."
    Write-Host "`t -cleaning up SQL db with prefix: [$spDbPrefix]"
   
    
    $dbs = Exec-SqlReaderQuery $sqlServerName "select name from dbo.sysdatabases"
    
    foreach($dbName in $dbs) {
        
        if($dbName.ToLower().StartsWith($spDbPrefix.ToLower()) -eq $true) {
            Exec-SqlQuery $sqlServerName "alter database [$dbName] set single_user with rollback immediate"
            Exec-SqlQuery $sqlServerName "drop database [$dbName]"
        }
    
    }

    Write-Host "`t -cleaning up SQL db with prefix: [$spDbPrefix] completed!"
}

Configuration SPFarm1
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SharePointDsc

    Node localhost {

        $DomainUserName = $Node.DomainUserName 
        $DomainUserPassword = $Node.DomainUserPassword 
    
        $passPhrase = $Node.PassPhrase 
    
        $secpasswd = ConvertTo-SecureString $DomainUserPassword -AsPlainText -Force
        $DomainCreds = New-Object System.Management.Automation.PSCredential($DomainUserName, $secpasswd)
        
        $secPassPhrase = ConvertTo-SecureString $passPhrase -AsPlainText -Force
        $PassPhraseCreds = New-Object System.Management.Automation.PSCredential($DomainUserName, $secPassPhrase)
    
        $SPSetupAccount = $DomainCreds
        $Passphrase = $PassPhraseCreds
        $FarmAccount = $DomainCreds
    
        $ServicePoolManagedAccount = $DomainCreds
        $WebPoolManagedAccount = $DomainCreds

        LocalConfigurationManager 
        {
            RebootNodeIfNeeded = $false
        }

        SPFarm CreateSPFarm
        {
            CentralAdministrationPort = 9999
            ServerRole               = "Custom"
            Ensure                   = "Present"
            DatabaseServer           = $sqlServerName
            FarmConfigDatabaseName   = ($spDbPrefix +  "_Config")
            Passphrase               = $Passphrase
            FarmAccount              = $FarmAccount
            PsDscRunAsCredential     = $SPSetupAccount
            AdminContentDatabaseName = ($spDbPrefix +  "_AdminContent")
            RunCentralAdmin          = $true
            #DependsOn                = "[SPInstall]InstallSharePoint"
        }

        # accounts

        SPManagedAccount ServicePoolManagedAccount
        {
            AccountName          = $ServicePoolManagedAccount.UserName
            Account              = $ServicePoolManagedAccount
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPFarm]CreateSPFarm"
        }
        SPManagedAccount WebPoolManagedAccount
        {
            AccountName          = $WebPoolManagedAccount.UserName
            Account              = $WebPoolManagedAccount
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        # default apps

        SPUsageApplication UsageApplication 
        {
            Name                  = "Usage Service Application"
            DatabaseName          = ($spDbPrefix + "_SP_Usage" ) 
            UsageLogCutTime       = 5
            UsageLogLocation      = "C:\UsageLogs"
            UsageLogMaxFileSizeKB = 1024
            PsDscRunAsCredential  = $SPSetupAccount
            DependsOn             = "[SPFarm]CreateSPFarm"
        }

        SPStateServiceApp StateServiceApp
        {
            Name                 = "State Service Application"
            DatabaseName         = ($spDbPrefix + "_SP_State")
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        SPDistributedCacheService EnableDistributedCache
        {
            Name                 = "AppFabricCachingService"
            Ensure               = "Present"
            CacheSizeInMB        = 1024
            ServiceAccount       = $ServicePoolManagedAccount.UserName
            PsDscRunAsCredential = $SPSetupAccount
            CreateFirewallRules  = $true
            DependsOn            = @('[SPFarm]CreateSPFarm','[SPManagedAccount]ServicePoolManagedAccount')
        }


        ## basic services
        SPServiceInstance ClaimsToWindowsTokenServiceInstance
        {  
            Name                 = "Claims to Windows Token Service"
            Ensure               = "Present"
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPFarm]CreateSPFarm"
        }   

        SPServiceInstance SecureStoreServiceInstance
        {  
            Name                 = "Secure Store Service"
            Ensure               = "Present"
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPFarm]CreateSPFarm"
        }
        
        SPServiceInstance ManagedMetadataServiceInstance
        {  
            Name                 = "Managed Metadata Web Service"
            Ensure               = "Present"
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        SPServiceInstance BCSServiceInstance
        {  
            Name                 = "Business Data Connectivity Service"
            Ensure               = "Present"
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPFarm]CreateSPFarm"
        }
        
        SPServiceInstance SearchServiceInstance
        {  
            Name                 = "SharePoint Server Search"
            Ensure               = "Present"
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        # service applications
        $serviceAppPoolName = "SharePoint Service Applications"
        SPServiceAppPool MainServiceAppPool
        {
            Name                 = $serviceAppPoolName
            ServiceAccount       = $ServicePoolManagedAccount.UserName
            PsDscRunAsCredential = $SPSetupAccount
            DependsOn            = "[SPFarm]CreateSPFarm"
        }

        SPSecureStoreServiceApp SecureStoreServiceApp
        {
            Name                  = "Secure Store Service Application"
            ApplicationPool       = $serviceAppPoolName
            AuditingEnabled       = $true
            AuditlogMaxSize       = 30
            DatabaseName          = ($spDbPrefix + "_SP_SecureStore")
            PsDscRunAsCredential  = $SPSetupAccount
            DependsOn             = "[SPServiceAppPool]MainServiceAppPool"
        }
        
        SPManagedMetaDataServiceApp ManagedMetadataServiceApp
        {  
            Name                 = "Managed Metadata Service Application"
            PsDscRunAsCredential = $SPSetupAccount
            ApplicationPool      = $serviceAppPoolName
            DatabaseName         = ($spDbPrefix + "_SP_MMS")
            DependsOn            = "[SPServiceAppPool]MainServiceAppPool"
        }

        SPBCSServiceApp BCSServiceApp
        {
            Name                  = "BCS Service Application"
            DatabaseServer        = $sqlServerName
            ApplicationPool       = $serviceAppPoolName
            DatabaseName          = ($spDbPrefix + "_SP_BCS")
            PsDscRunAsCredential  = $SPSetupAccount
            DependsOn             = @('[SPServiceAppPool]MainServiceAppPool', '[SPSecureStoreServiceApp]SecureStoreServiceApp')
        }

        SPSearchServiceApp SearchServiceApp
        {  
            Name                  = "Search Service Application"
            DatabaseName          = ($spDbPrefix + "_SP_Search")
            ApplicationPool       = $serviceAppPoolName
            PsDscRunAsCredential  = $SPSetupAccount
            DependsOn             = "[SPServiceAppPool]MainServiceAppPool"
        }
     }
}

$cd = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            RetryCount = 10           
            RetryIntervalSec = 30

            DomainUserName = $domainUserName
            DomainUserPassword = $domainUserPassword
            
            PassPhrase = $passPhrase
        }
    )
}

if(Test-Path SPFarm1)
{
    Remove-Item SPFarm1 -Recurse -Force
}

Write-Host "`t - running SharePoint DSC config..."

SPFarm1 -ConfigurationData $cd;
Start-DscConfiguration SPFarm1 -Force -Wait -Verbose 

Write-Host "`t - running SharePoint DSC config completed!"
