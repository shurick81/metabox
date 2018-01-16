# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Transferring files..."
Trace-MbEnv

# get it natively, it might be null under Vagrant, or Packer + VirtualBox on win2008 host
$http                 = $env:PACKER_HTTP_ADDR
$metaboxHttp =          $env:METABOX_HTTP_ADDR

$metaboxResourceName =  Get-MbEnvVariable "METABOX_RESOURCE_NAME"
$metaboxResourceDir  =  $env:METABOX_RESOURCE_DIR

function Validate-ExitCode($code, $message)
{
    if ($code -eq 0) {
        Log-MbInfoMessage "    Exit code is 0, continue..."
    } else {
        Log-MbInfoMessage "Exiting with non-zero code [$code] - $message" 
        throw "Exiting with non-zero code [$code] - $message" 
    }
}

function Get-HttpAddr()
{
    # by default, scans 8000-9000 ports
    # per default packer settings, http_port_min/http_port_max
    # https://www.packer.io/docs/builders/virtualbox-ovf.html
    Param(
        $ip = "10.0.2.2", 
        $portrange = 8000..9000, 
        $timeout_ms = 5
    )

    if (Test-Connection -BufferSize 32 -Count 1 -Quiet -ComputerName $ip)
    {
        Log-MbInfoMessage "IP $ip is alive... checking ports..."

        foreach ($port in $portrange)
        {
            $ErrorActionPreference = 'SilentlyContinue'

            $socket = new-object System.Net.Sockets.TcpClient
            $connect = $socket.BeginConnect($ip, $port, $null, $null)
            
            $tryconnect = Measure-Command { $success = $connect.AsyncWaitHandle.WaitOne($timeout_ms, $true) } | % totalmilliseconds
            $tryconnect | Out-Null

            if ($socket.Connected)
            {
                Log-MbInfoMessage "$ip is listening on port $port (Response Time: $tryconnect ms)"
                $socket.Close()
                $socket.Dispose()
                $socket = $null

                return ($ip + ":" + $port)
            }

            $ErrorActionPreference = 'Continue'
        }
    }

    throw "Cannot find alive http port on host: $ip"
}

if([String]::IsNullOrEmpty($http) -eq $true) {

    # are we under Vagrant VM provision and local METABOX_HTTP_ADDR?
    Log-MbInfoMessage "PACKER_HTTP_ADDR env var is null or empty. Checking METABOX_HTTP_ADDR variable"
    
    if([String]::IsNullOrEmpty($metaboxHttp) -eq $false) {
        Log-MbInfoMessage "Vagrant VM provision is detected, METABOX_HTTP_ADDR: $metaboxHttp"
        $http = $metaboxHttp
    } else {

        Log-MbInfoMessage "PACKER_HTTP_ADDR/METABOX_HTTP_ADDR env vars are null or empty. Scanning ports on 10.0.2.2..."

        $http = Get-HttpAddr
        Log-MbInfoMessage $http

        if([String]::IsNullOrEmpty($http) -eq $true) {
            throw "'PACKER_HTTP_ADDR/METABOX_HTTP_ADDR' env variable is null or empty, and scanning ports failed to resolve an open port"
        }

    }
} 

if([String]::IsNullOrEmpty($metaboxResourceName) -eq $true) {
    throw "'METABOX_RESOURCE_NAME' env variable is null or empty"
} 

if([String]::IsNullOrEmpty($metaboxResourceDir) -eq $true) {
    $metaboxResourceDir = "C:\_metabox_resources"
} 

function Ensure-Folder($path) {
    Log-MbInfoMessage "Ensuring folder: $path"
    New-Item -ItemType Directory -Force -Path $path
}

function Delete-Folder($path) {
    $path = $path + "\*"
    Log-MbInfoMessage "Deleting folder: $path"

    $attempts = 10
    $sleepTime = 6

    for($i = 0; $i -le $attempts; $i++) {
        Log-MbInfoMessage "  - attempt [$i/$attempts]"

        try {
            
            if(Test-Path $path) {
                Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue

                Log-MbInfoMessage "  waiting $sleepTime sec..."
                Start-Sleep -s $sleepTime
            } else {
                Log-MbInfoMessage "  deleted! all good!"
                break
            }
                
        } catch {
            Log-MbInfoMessage "Cannot delete path: $path - error was: $_"
            Log-MbInfoMessage "  waiting $sleepTime sec..."

            Start-Sleep -s $sleepTime
        }
    }
}

function Pull-RandomFile($http) {
    $fileName = "metabox-http-test.txt"
    
    $sourceFile = "$http/$fileName"
    $targetFile = "$env:TEMP/$fileName"
    
    # isn't used yet
    # $sourceFileMd5 = 'c3b62a675989c760fb3ae743444e926e'

    Log-MbInfoMessage "Source file is at $sourceFile"
    Log-MbInfoMessage "Target download location is $targetFile"

    Log-MbInfoMessage "Downloading file..."
    Invoke-WebRequest $sourceFile -OutFile $targetFile | Out-Null
    Log-MbInfoMessage "Done"

    return 0
}

function Pull-ZipResource($http, $resourceName, $targetResourceZipFolder) {

    # we'll try 15 zip packages with size of 500 Mb
    # that should be more that enough for most of the ISO packages
    # stupid, and works
    $resourceCount = 15

    # no more than 3, or download might fail and some resources won't be pulled
    # we tested with 10 on macbook - all good but fails on windows
    # 5 is ok, but we lowering down to 3 to make sure it's solid

    # the best guss is that 10 threads:
    # - either kill network on windows
    # - or HTTP sinatra server gets stuck
    $maxConcurrentJobs = 3
    $content = @()

    for($i = 1; $i -le $resourceCount; $i++) {
        $content += "http://$http/$resourceName/zip/dist.zip.0" + $i.ToString("00")
    }

    $Runspace = [runspacefactory]::CreateRunspacePool(1, $maxConcurrentJobs)
    $Runspace.Open()

    $jobs = @()

    foreach ($url in $content) {
       
        $ps = [powershell]::Create()
        $ps.RunspacePool = $Runspace

        $filePath = [System.IO.Path]::Combine($targetResourceZipFolder, [System.IO.Path]::GetFileName( $url ) )
        Log-MbInfoMessage "Saving: $url -> $filePath"
        [void]$ps.AddCommand("Invoke-WebRequest").AddParameter("Uri",$url).AddParameter("OutFile", $filePath)

        $jobs += New-Object PSObject -Property @{
            Pipe = $ps
            Result = $ps.BeginInvoke()
        }

        Log-MbInfoMessage ("Initiated request for {0}" -f $url)
    }

    Log-MbInfoMessage "Waiting.." -NoNewline
    Do {
        Log-MbInfoMessage "." -NoNewline
        Start-Sleep -Seconds 1
    } While ( $Jobs.Result.IsCompleted -contains $false )
    
    Log-MbInfoMessage "All jobs completed!"

    return $targetResourceZipFolder
}

function Unpack-ZipResource($resourceFolder, $zipFolder, $unpackZipFolder) {
    
    $oDest = "-o$unpackZipFolder"

    if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) {throw "$env:ProgramFiles\7-Zip\7z.exe needed"} 
    set-alias sz "$env:ProgramFiles\7-Zip\7z.exe" 

    Log-MbInfoMessage "Unpacking: $zipFolder/dist.zip.001 -> $unpackZipFolder"

    cd $zipFolder
    sz e -y "dist.zip.001" $oDest | Out-Null

    Validate-ExitCode $LASTEXITCODE "Failed to unpack zip for resource: $resourceFolder/dist.zip.001"

    # cleaning up zip folder early, once a succesfull ZIP unpack is done
    # overwise, it doubles the space
    Delete-Folder $zipFolder

    return $unpackZipFolder
}

function Unpack-IsoResource($isoFolder, $targetFolder) {
    cd $isoFolder

    $targetFile = Get-ChildItem -Filter *.iso | Select-Object -First 1

    if($targetFile -eq $null) {
        $targetFile = Get-ChildItem -Filter *.img | Select-Object -First 1
    }

    if($targetFile -ne $null) {

        $oDest = "-o$targetFolder"

        if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) {throw "$env:ProgramFiles\7-Zip\7z.exe needed"} 
        set-alias sz "$env:ProgramFiles\7-Zip\7z.exe" 

        Log-MbInfoMessage "`tUnpacking: $targetFile -> $resourcesFolder"
        sz x -y $targetFile $oDest

        Validate-ExitCode $LASTEXITCODE "Failed to unpack ISO for resource: $targetFile"


        Log-MbInfoMessage "`tDone"
    }
}

function Unpack-NonIsoResource($isoFolder, $targetFolder) {
    cd $isoFolder

    $targetFiles = Get-ChildItem -Exclude *.iso, *.img 

    if ($targetFiles -eq $null) {
        return
    }

    if( $targetFiles -isnot [System.Array]) {
        $targetFiles = @( $targetFiles )
    }

    foreach($targetFile in $targetFiles) {

        Log-MbInfoMessage "`tCopying: $targetFile -> $targetFolder"
        Copy-Item $targetFile $targetFolder -Force -Confirm:$false
        Log-MbInfoMessage "`tDone"
    }
}

function Pull-Resource($http, $resourceName, $resourcesFolder) {
    
    $targetResourceFolder = [System.IO.Path]::Combine($resourcesFolder, $resourceName)
    $zipFolder = [System.IO.Path]::Combine($targetResourceFolder, "__zip")
    $unpackZipFolder = [System.IO.Path]::Combine($targetResourceFolder, "__zip_unpacked")
    
    Ensure-Folder $targetResourceFolder
    Ensure-Folder $zipFolder
    Ensure-Folder $unpackZipFolder

    Log-MbInfoMessage "Downloading metabox resource: $resourceName to dir: $zipFolder"
    Pull-ZipResource $http $resourceName $zipFolder

    Log-MbInfoMessage "Unpaking zip resource: $zipFolder"
    Unpack-ZipResource $targetResourceFolder $zipFolder $unpackZipFolder

    Log-MbInfoMessage "Unpacking ISO: $unpackZipFolder -> $targetResourceFolder"
    Unpack-IsoResource $unpackZipFolder $targetResourceFolder 

    Log-MbInfoMessage "Unpacking non-ISO: $unpackZipFolder -> $targetResourceFolder"
    Unpack-NonIsoResource $unpackZipFolder $targetResourceFolder 

    Log-MbInfoMessage "Cleaning up..."
    
    Delete-Folder $zipFolder
    Delete-Folder $unpackZipFolder
}

Log-MbInfoMessage "Pulling random.txt file..."
Pull-RandomFile $http

Log-MbInfoMessage "Pulling resource: $metaboxResourceName"
Pull-Resource $http $metaboxResourceName $metaboxResourceDir

exit 0