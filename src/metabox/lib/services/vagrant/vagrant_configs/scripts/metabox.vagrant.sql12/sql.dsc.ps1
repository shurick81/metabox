# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Installing SQL Server..."
Trace-MbEnv

$binSourcePath = Get-MbEnvVariable "METABOX_SQL_BIN_PATH"
$instanceName = Get-MbEnvVariable "METABOX_SQL_INSTANCE_NAME"
$instanceFeatures = Get-MbEnvVariable "METABOX_SQL_INSTANCE_FEATURES"
$sqlSysAdminAccounts = (Get-MbEnvVariable "METABOX_SQL_SYS_ADMIN_ACCOUNTS").Split(',')

Configuration Install_SQL
{
    Import-DscResource -ModuleName xSQLServer

    Node localhost {

        LocalConfigurationManager 
        {
            RebootNodeIfNeeded = $false
        }

        WindowsFeature "NET-Framework-Core" 
        {
            Ensure="Present"
            Name = "NET-Framework-Core"
        }

        xSqlServerSetup "SQL"
        {
            DependsOn =           "[WindowsFeature]NET-Framework-Core"
            SourcePath =          $Node.BinSourcePath
            InstanceName =        $Node.InstanceName
            Features =            $Node.InstanceFeatures
            SQLSysAdminAccounts = $Node.SqlSysAdminAccounts
        }
    }

}

$config = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            RetryCount = 10           
            RetryIntervalSec = 30

            BinSourcePath = $binSourcePath
            InstanceName = $instanceName
            InstanceFeatures = $instanceFeatures
            SqlSysAdminAccounts = $sqlSysAdminAccounts
        }
    )
}

Apply-MbDSC "Install_SQL" $config 

exit 0