# http://www.hurryupandwait.io/blog/in-search-of-a-light-weight-windows-vagrant-box

Write-Host "Optimizing image size..."

Write-Host "Shrinking PageFile..."

try {
    $System = GWMI Win32_ComputerSystem -EnableAllPrivileges
    $System.AutomaticManagedPagefile = $False
    $System.Put()

    $CurrentPageFile = gwmi -query "select * from Win32_PageFileSetting where name='c:\\pagefile.sys'"
    $CurrentPageFile.InitialSize = 512
    $CurrentPageFile.MaximumSize = 512
    $CurrentPageFile.Put()
} catch {
    Write-Host "Error while shrinking PageFile: $_"
}

Write-Host "Cleaning up WinSXS debris..."
try {
    Dism.exe /online /Cleanup-Image /StartComponentCleanup 
} catch {
    Write-Host "Error while cleaning up WinSXS debris: $_"
}

Write-Host "Additional disk cleanup..."
try {
    C:\Windows\System32\cleanmgr.exe /d c:
} catch {
    Write-Host "Error while cleaning up disk: $_"
}

Write-Host "Optimizing volume..."
try {
    Optimize-Volume -DriveLetter C
} catch {
    Write-Host "Error while optimizing volume: $_"
}

Write-Host "Killing hidden data..."
try {
    Invoke-WebRequest http://download.sysinternals.com/files/SDelete.zip -OutFile sdelete.zip
    
    [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
    [System.IO.Compression.ZipFile]::ExtractToDirectory("sdelete.zip", ".") 
    
    ./sdelete.exe -z c: -accepteula
} catch {
    Write-Host "Error while killing hidden data: $_"
}