# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Validating Visual Studio install..."
Trace-MbEnv

$productName            = Get-MbEnvVariable "METABOX_VS_TEST_PRODUCT_NAME"
$officeToolsPackageName = Get-MbEnvVariable "METABOX_VS_TEST_OFFICETOOLS_PACKAGE_NAME"

Describe 'Visual Studio Install' {

    function Get-AppPackage($appName) {
    
        $result = @()
    
        $x32 = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
            | Select-Object DisplayName, Name, DisplayVersion, Publisher, InstallDate  `
            | Sort-Object "DisplayName" `
            | Where-Object { $_.DisplayName -ne $null -and $_.DisplayName.Contains($appName) } `
        
        $x64 = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
            | Select-Object DisplayName, Name, DisplayVersion, Publisher, InstallDate  `
            | Sort-Object "DisplayName" `
            | Where-Object { $_.DisplayName -ne $null -and $_.DisplayName.Contains($appName) } `
        
        $result += $x32
        $result += $x64
    
        return $result
    }

    function Is-App-Installed($appName) {
        $app = Get-AppPackage $appName

        if($app.Count -gt 1) {
            # TODO, very nasty :)
            $app = $app[0]
        }

        $app.DisplayName | Should BeLike "*$appName*"
    }

    Context "Visual Studio App" {

        It "$productName" {
            Is-App-Installed($productName)
        }

    }

    Context "Visual Studio Plugins" {
        
        It "$officeToolsPackageName" {
            Is-App-Installed("$officeToolsPackageName")
        }
    
     }
    
}
