# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"

$metaboxCoreScript = "c:/Windows/Temp/_metabox_core.ps1"
if(Test-Path $metaboxCoreScript) { . $metaboxCoreScript } else { throw "Cannot find core script: $metaboxCoreScript"}

Log-MbInfoMessage "Running windows SOE config..."
Trace-MbEnv

$computerName = $env:computername

$domainName =               Get-MbEnvVariable "METABOX_DC_DOMAIN_NAME"
$domainJoinUserName =       Get-MbEnvVariable "METABOX_DC_JOIN_USER_NAME"
$domainJoinUserPassword =   Get-MbEnvVariable "METABOX_DC_JOIN_USER_PASSWORD"
$domainIpAddr =             Get-MbEnvVariable "METABOX_DC_DOMAIN_HOST_IP"

Log-MbInfoMessage "Joining computer [$computerName] to domain [$domainName] under user [$domainJoinUserName]"
Log-MbInfoMessage "Running as :[$($env:UserDomain)/$($env:UserName)] on $($env:ComputerName)"

$securePassword = ConvertTo-SecureString $domainJoinUserPassword -AsPlainText -Force
$domainJoinUserCreds = New-Object System.Management.Automation.PSCredential($domainJoinUserName, $securePassword)

# helpers
Log-MbInfoMessage "Importing ActiveDirectory module..."
Import-Module ActiveDirectory

function Helper-RemoveADComputer
{
    Param(
        [Parameter(Mandatory=$True)]
        $computerName,
        
        [Parameter(Mandatory=$True)]
        $domainJoinUserCreds,

        [Parameter(Mandatory=$True)]
        $domainIpAddr 
    )

    $computer = $null

    try {
        Log-MbInfoMessage "Fetching computer from Active Directory: $computerName"

        $computer = get-adcomputer $computerName `
                        -ErrorAction SilentlyContinue `
                        -Credential $domainJoinUserCreds `
                        -Server $domainIpAddr
    } catch {

        Log-MbInfoMessage "There was an error while fetching computer from Active Directory:[$computerName]"
        Log-MbInfoMessage "Mostlikely, computer $computerName has never been added to Active Directory yet"

        Log-MbInfoMessage $_
        Log-MbInfoMessage $_.Exception

        $computer = $null
    }

    if($computer -ne $null) {
        Log-MbInfoMessage "Removing computer from Active Directory: $computerName"
        
        Remove-ADComputer -identity $computerName `
                            -Confirm:$false  `
                            -Credential $domainJoinUserCreds `
                            -Server $domainIpAddr

        Log-MbInfoMessage "Removed computer from Active Directory: $computerName"

    } else {
        Log-MbInfoMessage "No need to remove computer $computerName from Active Directory"
    }
}

Log-MbInfoMessage "Joining current computer to domain..."

if((Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain) {
    Log-MbInfoMessage "This computer, $computerName, is already part of domain. No domain join or reboot is required"
}
else {

    Log-MbInfoMessage "Deleting old computer from the domain..."
    Helper-RemoveADComputer $computerName $domainJoinUserCreds $domainIpAddr

    Log-MbInfoMessage "Joining computer to the domain..."

    try {
        if($computerName -ne $env:computername) {
            Log-MbInfoMessage "Joining computer with name [$($env:computername)] as [$computerName] to domain:[$domainName]"

            Add-Computer -DomainName $domainName `
                        -NewName $computerName `
                        -Credential $domainJoinUserCreds
        } else {
            Log-MbInfoMessage "Joining computer [$computerName] to domain [$domainName]"
            
            Add-Computer -DomainName $domainName `
                        -Credential $domainJoinUserCreds
        } 
    } catch {
        $errorMessage = $_.ToString()

        Log-MbInfoMessage "Error while adding ccomputer [$computerName] to domain [$domainName]"
        Log-MbInfoMessage $errorMessage 
        
        if($errorMessage.Contains("0x21c4") -eq $true) {
            Log-MbInfoMessage "!!! - Mostlikely, this image wasn't sysprep-ed: DC and client VMs have the same SID and won't even be joined. Run provision with syspreped image to join VMs to domain."
        }

        throw $_
    }

    Log-MbInfoMessage "Joining completed, a reboot is required"
}