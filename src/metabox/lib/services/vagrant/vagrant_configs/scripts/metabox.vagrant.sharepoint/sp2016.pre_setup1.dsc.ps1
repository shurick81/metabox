# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

# include shared halpers from metabox.vagrant.sharepoint handler
Include-MbSharedHandlerScript "metabox.vagrant.sharepoint" "sp.helpers.ps1"

Log-MbInfoMessage "Running SharePoint pre-setup1 tuning..."
Trace-MbEnv

# all this happens due to spoiled IIS installation after sysprep
# prereq/sp bin get IIS configured, but sysprep kills it
# we make some patches, and then uninstall IIS, and then run reboot
# once done, we bring Web-Server feature back and all works well

# patch IIS config
# https://forums.iis.net/t/1160389.aspx
Fix-MbIISApplicationHostFile

# uninstall web server feature
Uninstall-WindowsFeature Web-Server

exit 0