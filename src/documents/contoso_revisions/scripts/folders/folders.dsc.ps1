# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Configuration Configure_RevisionFolders {

    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName xNetworking
    
    Node localhost
    {
        File MetaboxRevisionFolder {
            Type = 'Directory'
            DestinationPath = 'C:\_metabox_revisions'
            Ensure = "Present"
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
        }
    )
}

Apply-MbDSC "Configure_RevisionFolders" $config 

exit 0