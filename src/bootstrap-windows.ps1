param(
    [String]$provisionMode = "dry-run"
)

# helpers
function Log-Message($msg, $color) {
    Write-Host $msg -Fore $color
}

function Log-InfoMessage($message) {
    Log-Message $message "Green"
}

function Log-VerboseMessage($message) {
    Log-Message $message "Gray"
}

function Log-WarnMessage($message) {
    Log-Message $message "Yellow"
}

function Log-ErrorMessage($message) {
    Log-Message $message "Red"
}

function Validate-ExitCode($code, $message)
{
    if ($code -eq 0) {
        Log-VerboseMessage "    Exit code is 0, continue..."
    } else {
        Log-ErrorMessage "Exiting with non-zero code [$code] - $message" 
        throw "Exiting with non-zero code [$code] - $message" 
    }
}

function CheckOrInstall-RequiredTool($provisionMode, $cmd, $installCmd) {

    $cmdObject = Get-Command -Name $cmd -ErrorAction SilentlyContinue

    if($cmdObject  -eq $null) {
        Log-WarnMessage "   [-] $cmd cannot be found, trying to install it..." 
        Log-WarnMessage "      cmd: $installCmd"

        if ($provisionMode -eq "--provision") {
            iex $installCmd
            Validate-ExitCode $LASTEXITCODE "Failed to install $cmd"
        } else {
            Log-ErrorMessage "       [!] dry-run mode, use --provision key to ALL software or use this cmd: $cmd"
        }
        
    } else {
        Log-InfoMessage "   [+] $cmd is here"
    }
}

# main flow
Log-InfoMessage "Installing Metabox prerequisites... Provision mode: $provisionMode"

CheckOrInstall-RequiredTool $provisionMode "choco" "Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"

CheckOrInstall-RequiredTool $provisionMode "ruby" 'choco install -y ruby'

CheckOrInstall-RequiredTool $provisionMode "git" 'choco install -y git'
CheckOrInstall-RequiredTool $provisionMode "wget.exe" 'choco install -y wget'
CheckOrInstall-RequiredTool $provisionMode "7z" 'choco install -y 7zip'
CheckOrInstall-RequiredTool $provisionMode "cmder" 'choco install -y cmder'

CheckOrInstall-RequiredTool $provisionMode "virtualbox" 'choco install -y virtualbox --version 5.1.22'

CheckOrInstall-RequiredTool $provisionMode "packer" 'choco install -y packer'
CheckOrInstall-RequiredTool $provisionMode "vagrant" 'choco install -y vagrant'

Log-InfoMessage "All green? - we are good to go with metabox!"