# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Running Visual Studio post-deploy script..."
Trace-MbEnv

$productName = Get-MbEnvVariable "METABOX_VS_PRODUCT_NAME"

if ($productName.Contains("2015") -eq $true) {
    Log-MbInfoMessage "Detected VS 2015 install. Ensuring additional plugins..."

    Log-MbInfoMessage "Installing Office Development tools via webpicmd"
    # https://github.com/mszcool/devmachinesetup/blob/master/Install-WindowsMachine.ps1
    webpicmd /Install /Products:OfficeToolsForVS2015 /AcceptEula
    Validate-MbExitCode $LASTEXITCODE "Cannot install Office Development tools"
    
} else {
    Log-MbInfoMessage "No post deploy is needed..."

}

Log-MbInfoMessage  "Visual Studio post-deploy script completed."

exit 0;