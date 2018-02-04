
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
    # use [environment]::UserDomainName / [environment]::UserName
    # $env:USERDOMAIN won't work on non-windows platforms
    $logMessage = "METABOX: $stamp : $level : $([environment]::UserDomainName)/$([environment]::UserName) : $message"

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

                if ($result.ResourcesNotInDesiredState -ne $null) {
                    foreach($resource in $result.ResourcesNotInDesiredState) {
                        Log-MbInfoMessage $resource
                    }
                }

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
    $value = $null
    
    try {
        $value = (get-item env:$x -ErrorAction SilentlyContinue).Value    
    } catch {

    }
    
    if([String]::IsNullOrEmpty($value) -eq $true) {
        $errorMessage = "Cannot find env variable by name: $name - $message, will try default value if provided"
        Log-MbInfoMessage $errorMessage 

        if($defaultValue -ne $null) {
            Log-MbInfoMessage "Using default value"
            Print-MbVariableValue $name $defaultValue 

            return $defaultValue
        } else {
            "Cannot find env variable by name: $name - $message, and no default value wer provided"
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

function Wait-MbProcess() {

    Param(
        [Parameter(Mandatory=$True)]
        $processName
    )

    while( ( get-process | Where-Object { $_.ProcessName.ToLower() -eq $processName } ) -ne $null) {
        Log-MbInfoMessage "$processName is still running... sleeping 5 sec.."
        Start-Sleep -Seconds 5
    } 
}

function Fix-MbIISApplicationHostFile {
    # https://forums.iis.net/t/1160389.aspx

    # You may be able to get into a working state by deleting 
    # the existing keys inside the configProtectedData section in applicationhost.config 
    # and then running "%windir%\system32\inetsrv\iissetup.exe /install SharedLibraries" 
    # - note that any existing encrypted properties in the cofig file is lost at this point, 
    # this should however setup up the encryption keys correctly to be able 
    # to write new encrypted properties.

    $filePath           = "C:\Windows\System32\inetsrv\config\applicationHost.config"
    $filePathFlagFile   = "C:\Windows\System32\inetsrv\config\applicationHost.config.metabox-patch-flag"

    $shouldUpdate = ((Test-Path $filePathFlagFile) -eq $false)

    if($shouldUpdate) {

        Log-MbInfoMessage "Fixing web server feature install..."
        Fix-WebServerInstall 

        Log-MbInfoMessage "Fixing up machine keys..."
        # fix machine keys for IIS after sysprep
        # http://rcampi.blogspot.com.au/2012/02/iis-75-cloning-machine-keys.html
        Fix-MbMachineKeys

        Log-MbInfoMessage "Cleaning up old machine keys..."
        Delete-MbOldMachineKeys

        Log-MbInfoMessage "Patching IISApplicationHostFile: $filePath"

        $xml = [xml](Get-Content $filePath)

        $configProtectedDataNode = $xml.configuration.configProtectedData

        Log-MbInfoMessage " - configProtectedData nodes count: $($configProtectedDataNode.providers.ChildNodes.Count)"

        if ($configProtectedDataNode.ChildNodes.Count -gt 0) {
            Log-MbInfoMessage " - cleaning up section: configuration.configProtectedData.providers"
            $configProtectedDataNode.RemoveChild($configProtectedDataNode.ChildNodes[0])

            Log-MbInfoMessage " - saving file: $filePath"
            $xml.Save($filePath)
        } else {
            Log-MbInfoMessage " - can't find sections in configuration.configProtectedData"
        }

        Log-MbInfoMessage "Running c:\windows\system32\inetsrv\iissetup.exe /install SharedLibraries, expecting '0' or 'Failed = 0x80070005'"
        c:\windows\system32\inetsrv\iissetup.exe /install SharedLibraries

        Log-MbInfoMessage " - adding flag file: $filePathFlagFile"
        "yes" > $filePathFlagFile
    } else {
        Log-MbInfoMessage "IISApplicationHostFile has already been patched..."
    }
}

function Delete-MbOldMachineKeys {
    $path = "C:\ProgramData\Microsoft\Crypto\RSA\S-1-5-18"
    
    if(Test-Path $path) {
        Log-MbInfoMessage "Deleting path: $path"
        Remove-Item $path -Recurse -Force
    } else {
        Log-MbInfoMessage "Path was already deleted: $path"
    }
}


function Fix-WebServerInstall {
    Log-MbInfoMessage "Running: Install-WindowsFeature web-server -IncludeAllSubFeature"
    Install-WindowsFeature Web-Server -IncludeAllSubFeature
}

function Fix-MbMachineKeys {

    # http://rcampi.blogspot.com.au/2012/02/iis-75-cloning-machine-keys.html

    #Variables
    $regGUIDPath = "HKLM:\SOFTWARE\Microsoft\Cryptography"
    $regGuidName = "MachineGuid"
    $machineKeyFolder = "C:\ProgramData\Microsoft\Crypto\RSA\MachineKeys"
    $key1 = "c2319c42033a5ca7f44e731bfd3fa2b5_"
    #$key2 = "7a436fe806e483969f48a894af2fe9a1_"
    $key2 = "76944fb33636aeddb9590521c2e8815a_"


    #Get Current GUID
    $machGUID =  (Get-ItemProperty -Path $regGUIDPath -Name $regGuidName).MachineGuid


    #Rename new one if it was created.  If IIS starts and there is no key, it will create a new one with new GUID
    if(test-path $machineKeyFolder\$key1$machGUID){
        ren "$machineKeyFolder\$key1$machGUID" "$key1$machGUID.OLD"
    }


    if(test-path $machineKeyFolder\$key2$machGUID){
        ren "$machineKeyFolder\$key2$machGUID" "$key2$machGUID.OLD"
    }
    #Now find the oldest key and rename it using the new machine GUID
    $files = Get-ChildItem ("$machineKeyFolder\*.*") -include ("$key1*") | sort-object -property ($_.CreationTime)


    foreach ($file in $files)
    {
        $fileName = $file.Name
        if (!$fileName.EndsWith($machGUID))
            {
                cp "$machineKeyFolder\$fileName" "$machineKeyFolder\$fileName.OLD"
                ren "$machineKeyFolder\$fileName" "$key1$machGUID"
                break


            }
    }


    $files = Get-ChildItem ("$machineKeyFolder\*.*") -include ("$key2*") | sort-object -property ($_.CreationTime)


    foreach ($file in $files)
    {
        $fileName = $file.Name
        if (!$fileName.EndsWith($machGUID))
            {
                cp "$machineKeyFolder\$fileName" "$machineKeyFolder\$fileName.OLD"
                ren "$machineKeyFolder\$fileName" "$key2$machGUID"
                break


            }
    }

}

function Safe-MbIISReset {
    Log-MbInfoMessage "Restarting IIS..." 
    iisreset
    Log-MbInfoMessage "Completed restarting IIS!" 

    Safe-MbIISPoolStart
}

function Safe-MbIISPoolStart {
    Import-Module WebAdministration

    Log-MbInfoMessage "Bringing up IIS pools..." 

    $pools = Get-ChildItem -Path 'IIS:\AppPools' 

    foreach($pool in $pools) {
        $name = $pool.Name

        Log-MbInfoMessage "Bringing up IIS pool: $name" 
        Start-WebAppPool -Name $name
    }
}

function Find-MbFileInPath {
    Param(
        [Parameter(Mandatory=$True)]
        $path,

        [Parameter(Mandatory=$False)]
        $ext = "exe"
    )

    $folder = $path

    # file or folder?
    if($path.ToUpper().EndsWith($ext.ToUpper()) -eq $true) {
        $folder  = Split-Path $path
    } else {
        $folder = $path
    }

    Log-MbInfoMessage "Looking for '$ext' file in folder: $path" 
    $exeFile = Get-ChildItem $folder -Filter "*.$ext"  | Select-Object -First 1 

    Log-MbInfoMessage " - found: $($exeFile.FullName)" 

    if($exeFile -eq $null -or $exeFile.Name -eq $null) {
        throw "Cannot find any '$ext' files in folder: $path" 
    }

    return $exeFile.FullName
}

function Install-MbPSModules {

    Param(
        [Parameter(Mandatory=$True)]
        $packages
    )

    foreach($package in $packages ) {

        Log-MbInfoMessage "`tinstalling package: $($package.Id) $($package.Version)"
        
        if ([System.String]::IsNullOrEmpty($package["Version"]) -eq $true) {
            Install-Module -Name $package["Id"] -Force;
        } else {
            Install-Module -Name $package["Id"] -RequiredVersion $package["Version"] -Force;
        }
    }
} 

function Fix-MbDCPromoSettings($domainAdminPass) {
    # https://aryannava.com/2012/01/05/administrator-password-required-error-in-dcpromo-exe/

    $message =  "Executing 'net user Administrator /passwordreq:yes' to bypass dcpromo errors"
    Log-MbInfoMessage $message 
    
    net user Administrator $domainAdminPass /passwordreq:yes
    Validate-MbExitCode $LASTEXITCODE "Failed to execute: $message"
}

function Disable-MbIP6Interface {
    Disable-NetAdapterBinding -InterfaceAlias "Ethernet" -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue 
    Disable-NetAdapterBinding -InterfaceAlias "Ethernet 2" -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
}