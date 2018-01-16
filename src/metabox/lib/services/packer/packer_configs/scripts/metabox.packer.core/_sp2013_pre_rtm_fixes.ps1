Write-Host "Running SharePoint 2013 RTM fixes..."

Write-Host "ServerManager fix"
# https://social.technet.microsoft.com/Forums/office/en-US/37cc20db-6cc7-45e0-928c-9a1ddbdab2ae/the-tool-was-unable-to-install-application-server-role-web-server-iis-role?forum=sharepointadmin

if ( !(Test-Path "C:\windows\System32\ServerManagerCMD.exe") ) {
    Copy-Item "C:\windows\System32\ServerManager.exe" "C:\windows\System32\ServerManagerCMD.exe" -Force -ErrorAction SilentlyContinue
}

Write-Host "Checking if prerequisiteinstaller is still running..."

while( ( get-process | Where-Object { $_.ProcessName.ToLower() -eq "prerequisiteinstaller" } ) -ne $null) {
    Write-Host "prerequisiteinstaller is still running... sleeping 5 sec.."
    Start-Sleep -Seconds 5
}

Write-Host "Running prerequisiteinstaller..."

$SharePoint2013SP1Path = "C:\_metabox_resources\sp2013_prerequisites"
$process = "C:\_metabox_resources\sp2013server_rtm\prerequisiteinstaller.exe"

$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = $process
$pinfo.UseShellExecute = $true

$pinfo.Arguments = "/unattended 
/SQLNCli:$SharePoint2013SP1Path\sqlncli.msi 
/IDFX:$SharePoint2013SP1Path\Windows6.1-KB974405-x64.msu 
/IDFX11:$SharePoint2013SP1Path\MicrosoftIdentityExtensions-64.msi 
/Sync:$SharePoint2013SP1Path\Synchronization.msi 
/AppFabric:$SharePoint2013SP1Path\WindowsServerAppFabricSetup_x64.exe 
/KB2671763:$SharePoint2013SP1Path\AppFabric1.1-RTM-KB2671763-x64-ENU.exe 
/MSIPCClient:$SharePoint2013SP1Path\setup_msipc_x64.msi 
/WCFDataServices:$SharePoint2013SP1Path\WcfDataServices-5.0.exe"

$p = New-Object System.Diagnostics.Process
$p.StartInfo = $pinfo
$p.Start() | Out-Null
$p.WaitForExit()

Write-Host "Exit code: $($p.ExitCode)"

if($p.ExitCode -eq 3010) {
    exit 0
}

exit $p.ExitCode