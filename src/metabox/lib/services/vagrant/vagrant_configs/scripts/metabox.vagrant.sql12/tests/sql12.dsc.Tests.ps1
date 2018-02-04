# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Testing SQL Server setup..."
Trace-MbEnv

$instanceFeatures = Get-MbEnvVariable "METABOX_SQL_INSTANCE_FEATURES"

# such as SQLENGINE,SSMS,ADV_SSMS
$instanceFeaturesArray = $instanceFeatures.Split(',')

$checkSQLEngine = $instanceFeaturesArray.Contains("SQLENGINE") -eq $true
$checkSSMS      = $instanceFeaturesArray.Contains("SSMS") -eq $true

Describe 'SQL Server 2012 minimal configuration' {

    # always test SQL server itself
    Context "SQL Server" {
        
         It 'MSSQL service is running' {
            (get-service MSSQLSERVER).Status | Should BeLike "Running"
         }

         It 'MSSQL AGENT service is running' {
            (get-service SQLSERVERAGENT).Status | Should BeLike "Running"
        }
 
     }

    # only if
    Context "SQL Tools" {
       
        It 'ssms.exe is installed' {
            if($checkSSMS -eq $true)  {
                 get-command ssms | Should BeLike "*ssms.exe*"
            } else {
                Log-MbInfoMessage "Skipping ssms.exe check"
            }
        }

    }
    
}
