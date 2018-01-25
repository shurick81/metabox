param ([String] $ip, [String] $dns)

# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Fixing up network settings..."
Trace-MbEnv

# if (Test-Path C:\Users\vagrant\enable-winrm-after-customization.bat) {
#   Log-MbInfoMessage "Nothing to do in vCloud."
#   exit 0
# }
# if (! (Test-Path 'C:\Program Files\VMware\VMware Tools')) {
#   Log-MbInfoMessage "Nothing to do for other providers than VMware."
#   exit 0
# }

$subnet = $ip -replace "\.\d+$", ""

Log-MbInfoMessage " - ip    : $ip"
Log-MbInfoMessage " - subnet: $subnet"

$name = (Get-NetIPAddress -AddressFamily IPv4 `
   | Where-Object -FilterScript { ($_.IPAddress).StartsWith($subnet) } `
   ).InterfaceAlias

if (!$name) {
  $name = (Get-NetIPAddress -AddressFamily IPv4 `
     | Where-Object -FilterScript { ($_.IPAddress).StartsWith("169.254.") } `
     ).InterfaceAlias
}

if ($name) {
  Log-MbInfoMessage "Set IP address to $ip of interface $name"
  & netsh.exe int ip set address "$name" static $ip 255.255.255.0 "$subnet.1"
  
  Validate-MbExitCode $LASTEXITCODE "Cannot set IP address to $ip of interface $name" @(0,1)

  if ($dns) {
    Log-MbInfoMessage "Set DNS server address to $dns of interface $name"
    & netsh.exe interface ipv4 add dnsserver "$name" address=$dns index=1

    Validate-MbExitCode $LASTEXITCODE "Cannot set DNS server address to $dns of interface $name" @(0,1)
  }
} else {
  $errorMessage = "Could not find a interface with subnet $subnet.xx"

  Log-MbInfoMessage $errorMessage
  throw $errorMessage
}

Log-MbInfoMessage "Running ipconfig..."
& ipconfig 
Validate-MbExitCode $LASTEXITCODE "Cannot run ipconfig"

exit 0