
function global:Load-MbAssembly {
    
    Param(
        [Parameter(Mandatory=$True)]
        [String]$assemblyName
    )

    $assembly = [System.Reflection.Assembly]::LoadWithPartialName($assemblyName)

    if ($assembly -eq $null) {
        $errorMessage = "Cannot load assembly by its name: $assemblyName"
        
        Log-MbInfoMessage $errorMessage
        throw $errorMessage
    } else {
        $errorMessage = "Loaded assembly by name: $assemblyName"
    }
}

function global:Load-MbAssemblies {

    Param(
        [Parameter(Mandatory=$True)]
        [String[]]$assemblyNames
    )

    foreach($assemblyName in $assemblyNames) {
        Load-MbAssembly $assemblyName
    }
}

function global:Get-MbSPConfigDbDNS($majorVersion) {
    
    if($majorVersion -eq $null) {
        $majorVersion = "15"
    }

    $regPath = "HKLM:\SOFTWARE\Microsoft\Shared Tools\Web Server Extensions\$majorVersion.0\Secure\ConfigDB"
    $item = Get-ItemProperty  $regPath -ErrorAction SilentlyContinue

    if($item -eq $null) {
        return $null
    }

    return $item.dsn
}
    
function global:Exec-MbSqlQuery($server, $query) {
    Log-MbInfoMessage "Annoying SQL server [$server] with query [$query]"

    $connection = New-Object "System.Data.SqlClient.SqlConnection" `
                -ArgumentList  @("Server = $server; Database = master; Integrated Security = True;")


    $connection.Open()
    
    $sqlCommand = New-Object "System.Data.SqlClient.SqlCommand" -ArgumentList @($query, $connection);
    $reader = $sqlCommand.ExecuteNonQuery()
    $connection.Close()
}

function global:Exec-MbSqlReaderQuery($server, $query) {
    Log-MbInfoMessage "Annoying SQL server [$server] with query [$query]"

    $result = @()

    $connection = New-Object "System.Data.SqlClient.SqlConnection" `
                -ArgumentList  @("Server = $server; Database = master; Integrated Security = True;")


    #$sqlCommandText = $query;
    $connection.Open()
    
    $sqlCommand = New-Object "System.Data.SqlClient.SqlCommand" -ArgumentList @($query, $connection);
    $reader = $sqlCommand.ExecuteReader()

    while( $reader.Read() -eq $true) {
        $result += $reader.GetValue(0)
        #Log-MbInfoMessage "Result: [$($reader.GetValue(0))]"
    }

    $connection.Close()

    return $result
}

function global:Delete-MbSqlDb($name) {
    $sqlCommandText = "DROP DATABASE $name";
    $sqlCommand = New-Object System.DateSqlCommand -arguments ($sqlCommandText, $connection);
    $sqlCommand.ExecuteNonQuery();
}

function global:Is-MbSPInstalled {
    # assuming SharePoint 2013 by default
    $configDbDns = Get-MbSPConfigDbDNS 15

    # checking if SharePoint 2016 is here
    if($configDbDns -eq $null ) {
        $configDbDns = Get-MbSPConfigDbDNS 16
    }

    Log-MbInfoMessage "Detected config Db DNS:[$configDbDns]"
    $isSharePointInstalled = ($configDbDns -ne $null)

    return $isSharePointInstalled
}

function global:Prepare-MbSPSqlServer {
    Param(
        [Parameter(Mandatory=$True)]
        [String]$spSqlServerName,

        [Parameter(Mandatory=$True)]
        [String]$spSqlDbPrefix
    )

    Log-MbInfoMessage "Preparing SQL Server [$spSqlServerName] for SharePoint deployment. DBs prefix: $spSqlDbPrefix"

    # prepare SQL Server for SharePoint deployment
    $isSharePointInstalled = Is-MbSPInstalled   

    if($isSharePointInstalled) {
        Log-MbInfoMessage "Detected that SharePoint is already installed. No need to create Farm or Join to farm"
    } else {
        Cleanup-MbSPSqldatabases $spSqlServerName $spSqlDbPrefix 
    }
}

function global:Cleanup-MbSPSqldatabases {

    Param(
        [Parameter(Mandatory=$True)]
        [String]$spSqlServerName,

        [Parameter(Mandatory=$True)]
        [String]$spSqlDbPrefix
    )

    Load-MbAssemblies @(
        "System.Data"
    )

    Log-MbInfoMessage "`t - cleaning up SQL databases with prefix: $spSqlDbPrefix"
    
    $dbs = Exec-MbSqlReaderQuery $spSqlServerName "select name from dbo.sysdatabases"
    
    foreach($dbName in $dbs) {
        if($dbName.ToLower().StartsWith($spSqlDbPrefix.ToLower()) -eq $true) {
            Exec-MbSqlQuery $spSqlServerName "alter database [$dbName] set single_user with rollback immediate"
            Exec-MbSqlQuery $spSqlServerName "drop database [$dbName]"
        }
    }    
}