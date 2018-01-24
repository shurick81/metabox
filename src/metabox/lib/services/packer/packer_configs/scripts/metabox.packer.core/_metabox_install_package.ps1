# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Installing package..."
Trace-MbEnv

$packageName        = Get-MbEnvVariable "METABOX_APP_PACKAGE_NAME"
$packageFilePath    = Get-MbEnvVariable "METABOX_APP_PACKAGE_FILE_PATH"
$silentArgs         = Get-MbEnvVariable "METABOX_APP_PACKAGE_SILENT_ARGS"
$exitCodes          = Get-MbEnvVariable "METABOX_APP_PACKAGE_EXIT_CODES"
$fileType           = Get-MbEnvVariable "METABOX_APP_PACKAGE_FILE_TYPE" "default value" "msu"

$exitCodes = $exitCodes.split(',')

$result = Install-MbInstallPackage -filePath $packageFilePath `
                        -packageName $packageName `
                        -silentArgs $silentArgs `
                        -validExitCodes $exitCodes `
                        -fileType $fileType

exit $result