
function Include-MbScript {

    Param(
        [Parameter(Mandatory=$True)]
        [String]$scriptPath
    )

    # we really like to test if file exists before adding it
    # the problem is that dot-sourcing would add functions under the current scope
    # not exposing it to the global scope

    # hence, either a super magic needs to be used
    # or we just write all our common scripts and functino in global:function format

    if(Test-Path $scriptPath) { 

        # https://stackoverflow.com/questions/15187510/dot-sourcing-functions-from-file-to-global-scope-inside-of-function

        #$scriptContent = Get-Content $scriptPath
        #$scriptContent = $scriptContent -replace '^function\s+((?!global[:]|local[:]|script[:]|private[:])[\w-]+)', 'function Global:$1'
        
        #Log-MbMessage $scriptContent

        #. ([scriptblock]::Create($scriptContent))

        . $scriptPath 
    } else { 
        throw "Cannot find PowerShell script: $scriptPath"
    }

}

function Include-MbSharedHandlerScript {

    Param(
        [Parameter(Mandatory=$True)]
        [String]$handlerName,

        [Parameter(Mandatory=$True)]
        [String]$scriptName
    )

    $scriptPath = "c:/Windows/Temp/$handlerName/shared/$scriptName"
    Log-MbMessage "Including shared handler script: $handlerName, $scriptName, from: $scriptPath"

    Include-MbScript $scriptPath 
}


function Log-MbMessage($message, $level) {
    $stamp = $(get-date -f "MM-dd-yyyy HH:mm:ss.fff")
    $logMessage = "METABOX: $stamp : $level : $($env:USERDOMAIN)/$($env:USERNAME) : $message"

    Write-Host $logMessage
}

function Log-MbInfoMessage($message) {
    Log-MbMessage "$message" "INFO"
}

function Validate-MbExitCode {
    Param(
        [Parameter(Mandatory=$True)]
        $code,
        
        [Parameter(Mandatory=$True)]
        $message,

        [Parameter(Mandatory=$False)]
        $allowedCodes = @( 0 )
    )

    $valid = $false

    Log-MbInfoMessage "Checking exit code: $code with allowed values: $allowedCodes"

    foreach ($allowedCode in $allowedCodes) {
        if($code -eq $allowedCode) {
            $valid = $true
            break
        }
    }
    
    if( $valid -eq $false) {
        $error_message =  "$message - exit code is: $code but allowed values were: $allowedCodes"
        
        Log-MbInfoMessage $error_message
        throw $error_message
    } else {
        Log-MbInfoMessage "Exit code is: $code within allowed values: $allowedCodes"
    }

    return $code
}

if([String]::IsNullOrEmpty($metaboxResourceDir) -eq $true) {
    $metaboxResourceDir = "C:\_metabox_resources"
} 

function Ensure-MbFolder($path) {
    New-Item -ItemType Directory -Force -Path $path | out-null
}

function Get-MbDSCConfig {
    return @{
        AllNodes = @(
            @{
                NodeName = 'localhost'
                PSDscAllowPlainTextPassword = $true

                RetryCount = 10           
                RetryIntervalSec = 30
            }
        )
    }
}

function Apply-MbDSC {
    Param(
        [Parameter(Mandatory=$True)]
        $name,
        
        [Parameter(Mandatory=$False)]
        $config = $null,

        [Parameter(Mandatory=$False)]
        $expectInDesiredState = $null
    )

    $skipDscCheck = $false

    if($config -eq $null) {
        $config = Get-MbDSCConfig
    }

    # should check?
    if($ENV:METABOX_DSC_CHECK -ne $null -and $expectInDesiredState -eq $null) {
        $expectInDesiredState = $true
    }

    if($ENV:METABOX_DSC_CHECK_SKIP -ne $null) {
        $skipDscCheck = $true
    }

    $dscFolder = "C:\_metabox_dsc"
    $dscConfigFolder = [System.IO.Path]::Combine($dscFolder, $name)

    Log-MbInfoMessage "Ensuring folder: $path for config: $name"
    Ensure-MbFolder $dscFolder

    Log-MbInfoMessage "Clearing previous configuration: $name"
    if(Test-Path $dscConfigFolder) {
        Remove-Item $dscConfigFolder -Recurse -Force
    }

    Log-MbInfoMessage "Compiling new configuration: $name"
    . $name -ConfigurationData $config -OutputPath $dscConfigFolder

    Log-MbInfoMessage "Starting configuration: $name"
    Start-DscConfiguration -Path $dscConfigFolder -Force -Wait -Verbose

    $result = $null

    if($skipDscCheck -eq $false) {

        Log-MbInfoMessage "Testing configuration: $name"
        $result = Test-DscConfiguration -Path $dscConfigFolder

        if($expectInDesiredState -eq $true) {
            Log-MbInfoMessage "Expecting DSC [$name] in a desired state"

            if($result.InDesiredState -ne $true) {
                $message = "DSC: $name - is NOT in a desired state: $result"
                Log-MbInfoMessage $message
                throw $message
            } else {
                $message = "DSC: $name is in a desired state: $result"
                Log-MbInfoMessage $message
            }
        } else {
            Log-MbInfoMessage "No check for DSC [$name] is done. Skipping."
        }
    } else {
        Log-MbInfoMessage "Skipping testing configuration: $name"
    }

    return  $result
}

function Print-MbVariableValue($name, $value, $indentation) {
    $isSecterVariable = Is-MbSecterVariableName $name

    if([String]::IsNullOrEmpty($indentation) -eq $true) {
        $indentation = ""
    }

    if($isSecterVariable -eq $true) {
        Log-MbInfoMessage "$indentation[ENV:$name]: ******"
    } else {
        Log-MbInfoMessage "$indentation[ENV:$name]: $value"
    }
}

function Trace-MbEnv
{
    Log-MbInfoMessage "Running as:[$($env:UserDomain)\$($env:UserName)]"
    Log-MbInfoMessage "All env vars --- START --------------------------------------"
    
    $props = Get-ChildItem Env:

    foreach($prop in $props) {
        $name = $prop.Name
        $value = $prop.Value

        Print-MbVariableValue $name $value "`t"
    }
    
    Log-MbInfoMessage "All env vars --- END ----------------------------------------"
}

function Is-MbSecterVariableName($name) {
    return $name.ToUpper().Contains("_KEY") -or  $name.ToUpper().Contains("_PASSWORD")
}



function Get-MbEnvVariable($name, $message, $defaultValue) {
    
    $x = $name
    $value = (get-item env:$x).Value    
    
    if([String]::IsNullOrEmpty($value) -eq $true) {
        $errorMessage = "Cannot find env variable by name: $name - $message"
        Log-MbInfoMessage $errorMessage 

        if($defaultValue -ne $null) {
            
        }

        throw $errorMessage 
    } else {
        Print-MbVariableValue $name $value 
    }

    return $value
}

function Install-MbInstallPackage {

    Param(
        [Parameter(Mandatory=$True)]
        $filePath,
        
        [Parameter(Mandatory=$True)]
        $packageName,

        [Parameter(Mandatory=$True)]
        $silentArgs,

        [Parameter(Mandatory=$True)]
        $validExitCodes,

        [Parameter(Mandatory=$False)]
        $fileType,
        
        [Parameter(Mandatory=$False)]
        $chocolateyInstallerPath 
    )

    # this is a wrap up of boxstarter and chocolatey
    # idea is to get KBs installed in "offline" mode out of metabox file resources

    # https://github.com/riezebosch/BoxstarterPackages/blob/master/KB2919355/Tools/ChocolateyInstall.ps1
    # https://github.com/chocolatey/choco/blob/e96fb159e0957d9e2fee1e738d42dcc414957c91/src/chocolatey.resources/helpers/functions/Install-ChocolateyPackage.ps1

    if($chocolateyInstallerPath -eq $null) {
        $chocolateyInstallerPath  = "C:\ProgramData\chocolatey\helpers\chocolateyInstaller.psm1"
    }

    if($fileType -eq $null) {
        $fileType  = "msu"
    }

    if (Get-HotFix -id $packageName -ea SilentlyContinue)
    {
        Log-MbInfoMessage "Skipping installation, package is already installed: $packageName"
        return 0
    }

    Log-MbInfoMessage "Importing Chocolatey install helper: $chocolateyInstallerPath" 
    Import-Module $chocolateyInstallerPath

    Log-MbInfoMessage "Installing package:" 
    Log-MbInfoMessage "`t - PackageName: $packageName" 
    Log-MbInfoMessage "`t - SilentArgs: $silentArgs" 
    Log-MbInfoMessage "`t - File: $filePath" 
    Log-MbInfoMessage "`t - FileType: $fileType" 
    Log-MbInfoMessage "`t - ValidExitCodes: $validExitCodes" 
    
    $result = Install-ChocolateyInstallPackage  -PackageName $packageName `
                                                -SilentArgs $silentArgs `
                                                -File $filePath `
                                                -FileType $fileType `
                                                -ValidExitCodes $validExitCodes

    Log-MbInfoMessage "Finished installation, result: $result" 

    return $result
}