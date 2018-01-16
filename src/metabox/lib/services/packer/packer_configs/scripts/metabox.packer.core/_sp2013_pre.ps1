
$installDir = $ENV:METABOX_INSTALL_DIR

if($installDir -eq $null) {
    throw "METABOX_INSTALL_DIR env var is null or empty"
} else {
    Write-Host "Using [ENV:METABOX_INSTALL_DIR]: $installDir"
}

Write-Host "Checking if prerequisiteinstaller is still running..."

while( ( get-process | Where-Object { $_.ProcessName.ToLower() -eq "prerequisiteinstaller" } ) -ne $null) {
    Write-Host "prerequisiteinstaller is still running... sleeping 5 sec.."
    Start-Sleep -Seconds 5
}

Write-Host "Running DSC: SP2013_InstallPrereqs"

Configuration SP2013_InstallPrereqs
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

        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $False
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

            InstallDir = $installDir
        }
    )
}

if(Test-Path SP2013_InstallPrereqs)
{
    Remove-Item SP2013_InstallPrereqs -Recurse -Force
}

Write-Host "`t - running SP2013_InstallPrereqs DSC config..."

SP2013_InstallPrereqs -ConfigurationData $cd;
Start-DscConfiguration SP2013_InstallPrereqs -Force -Wait -Verbose 

$result = Test-DscConfiguration SP2013_InstallPrereqs
Write-Host $result

if($ENV:METABOX_DSC_CHECK -ne $null) {
    Write-Host "METABOX_DSC_CHECK: $($ENV:METABOX_DSC_CHECK)"
    Write-Host "Expecting DSC in a desired state"

    if($result.InDesiredState -ne $true) {
        Write-Host "DSC Resource is not in a desired state"
        exit -1
    }
} else {
    Write-Host "METABOX_DSC_CHECK: $($ENV:METABOX_DSC_CHECK)"
    Write-Host "No DSC check is needed"
}

Write-Host "`t - running SP2013_InstallPrereqs DSC config completed!"