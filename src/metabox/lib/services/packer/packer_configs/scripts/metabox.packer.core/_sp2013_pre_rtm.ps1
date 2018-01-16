
# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"
. "c:/Windows/Temp/_metabox_core.ps1"

$installDir = $ENV:METABOX_INSTALL_DIR
$preReqDir = $ENV:METABOX_PREREQ_DIR
$offline = $ENV:METABOX_PREREQ_OFFLINE

Log-MbInfoMessage "Using [ENV:METABOX_PREREQ_OFFLINE]: $offline"

if($installDir -eq $null) {
    $m = "METABOX_INSTALL_DIR env var is null or empty"
    Log-MbInfoMessage $m 
    throw $m 
} else {
    Log-MbInfoMessage "Using [ENV:METABOX_INSTALL_DIR]: $installDir"
}

if($offline -ne $null -and $preReqDir -eq $null) {
    throw "METABOX_PREREQ_DIR env var is null or empty"
} else {
    Log-MbInfoMessage "Using [ENV:METABOX_PREREQ_DIR]: $preReqDir"
}

Log-MbInfoMessage "Checking if prerequisiteinstaller is still running..."

while( ( get-process | Where-Object { $_.ProcessName.ToLower() -eq "prerequisiteinstaller" } ) -ne $null) {
    Log-MbInfoMessage "prerequisiteinstaller is still running... sleeping 5 sec.."
    Start-Sleep -Seconds 5
}

Log-MbInfoMessage "Running DSC: SP2013_InstallPrereqs"
Configuration SP2013_RTM_InstallPrereqs_Online
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SharePointDsc

    node "localhost"
    {        
        SPInstallPrereqs InstallPrereqs {
            Ensure            = "Present"
            InstallerPath     = ($Node.InstallDir + "\prerequisiteinstaller.exe")
            
            OnlineMode        = $true
        }
    }
}

Configuration SP2013_RTM_InstallPrereqs_Offline
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SharePointDsc

    node "localhost"
    {        
        SPInstallPrereqs InstallPrereqs {
            Ensure            = "Present"
            InstallerPath     = ($Node.InstallDir + "\prerequisiteinstaller.exe")
            
            OnlineMode        = $false

            # NET 35 is meant to be installed early with the "app" image so to avoid SXS roundtrip
            #SXSpath           = "c:\SPInstall\Windows2012r2-SXS"
            SQLNCli           = ($Node.PrereqDir + "\sqlncli.msi")
            PowerShell        = ($Node.PrereqDir + "\Windows6.1-KB2506143-x64.msu")
            NETFX             = ($Node.PrereqDir + "\dotNetFx45_Full_setup.exe")
            IDFX              = ($Node.PrereqDir + "\Windows6.1-KB974405-x64.msu")
            Sync              = ($Node.PrereqDir + "\Synchronization.msi")
            AppFabric         = ($Node.PrereqDir + "\WindowsServerAppFabricSetup_x64.exe")
            IDFX11            = ($Node.PrereqDir + "\MicrosoftIdentityExtensions-64.msi")
            MSIPCClient       = ($Node.PrereqDir + "\setup_msipc_x64.msi")
            WCFDataServices   = ($Node.PrereqDir + "\WcfDataServices-5.0.exe")
            KB2671763         = ($Node.PrereqDir + "\AppFabric1.1-RTM-KB2671763-x64-ENU.exe")
            WCFDataServices56 = ($Node.PrereqDir + "\WcfDataServices-5.6.exe")
        }

        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $False
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

            InstallDir = $installDir
            PrereqDir = $preReqDir
        }
    )
}

if( $offline -ne $null) {
    Apply-MbDSC "SP2013_RTM_InstallPrereqs_Offline" $config 
} else {
    Apply-MbDSC "SP2013_RTM_InstallPrereqs_Online" $config 
}

exit 0