# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Installing 7z and PowerShell software..."
Trace-MbEnv

Log-MbInfoMessage "Set-ExecutionPolicy Bypass -Force"
Set-ExecutionPolicy Bypass -Force; 

Log-MbInfoMessage "Installing chocolatey..."
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); 
Validate-MbExitCode $LASTEXITCODE "Cannot install chocolatey"

Log-MbInfoMessage "choco install -y 7zip..."
choco install -y 7zip; 
Validate-MbExitCode $LASTEXITCODE "Cannot install 7zip"

if($psversiontable.PSVersion.Major -ne 5) {
    Log-MbInfoMessage "Major version of POwerShell below 5. Installing PowerShell, and a reboot is required"
    choco install -y powershell; 
    Validate-MbExitCode $LASTEXITCODE "Cannot install powershell" @(0, 3010)

    $LASTEXITCODE = 0;     
}

exit 0; 