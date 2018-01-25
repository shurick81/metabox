# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Optimizing image size..."
Trace-MbEnv

# http://www.hurryupandwait.io/blog/in-search-of-a-light-weight-windows-vagrant-box

Log-MbInfoMessage "Shrinking PageFile..."

try {
    $System = GWMI Win32_ComputerSystem -EnableAllPrivileges
    $System.AutomaticManagedPagefile = $False
    $System.Put()

    $CurrentPageFile = gwmi -query "select * from Win32_PageFileSetting where name='c:\\pagefile.sys'"
    $CurrentPageFile.InitialSize = 512
    $CurrentPageFile.MaximumSize = 512
    $CurrentPageFile.Put()
} catch {
    Log-MbInfoMessage "Error while shrinking PageFile: $_"
}

Log-MbInfoMessage "Cleaning up WinSXS debris..."
try {
    Dism.exe /online /Cleanup-Image /StartComponentCleanup 
} catch {
    Log-MbInfoMessage "Error while cleaning up WinSXS debris: $_"
}

Log-MbInfoMessage "Additional disk cleanup..."
try {
    C:\Windows\System32\cleanmgr.exe /d c:
} catch {
    Log-MbInfoMessage "Error while cleaning up disk: $_"
}

Log-MbInfoMessage "Optimizing volume..."
try {
    Optimize-Volume -DriveLetter C
} catch {
    Log-MbInfoMessage "Error while optimizing volume: $_"
}

Log-MbInfoMessage "Killing hidden data..."
try {
    Invoke-WebRequest http://download.sysinternals.com/files/SDelete.zip -OutFile sdelete.zip
    
    [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
    [System.IO.Compression.ZipFile]::ExtractToDirectory("sdelete.zip", ".") 
    
    ./sdelete.exe -z c: -accepteula
} catch {
    Log-MbInfoMessage "Error while killing hidden data: $_"
}

exit 0