function _GetJson(){
    param(
    [string]$logMessage,
    [string]$logLevel,
    [System.Collections.Hashtable]$logProps = @{}
    )
    $now = (Get-Date).ToString("o")
    
    # Ordered hash table to ensure that the json is rendered in the desired order.
    $jsonObj = [ordered]@{
        Timestamp=$now;
        Level=$logLevel;
        Message=$logMessage;
    }

    foreach($key in $logProps.Keys){
        $jsonObj[$key] = $logProps[$key]
    }
	
    if(-not [string]::IsNullOrEmpty($PSLogName)){
        $jsonObj["logname"] = $PSLogName
    }

    $jsonObj["host"] = [Environment]::MachineName

    return ConvertTo-Json $jsonObj -Compress
}

function _ArchiveLogFile(){
    $withoutExtension = [IO.Path]::GetFileNameWithoutExtension($PSLogFilePath)
    $extension = [IO.Path]::GetExtension($PSLogFilePath)
    $newPath = [IO.Path]::GetDirectoryName($PSLogFilePath) + "\" + $withoutExtension + "_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + $extension
    Move-Item $PSLogFilePath $newPath
}

function _WriteToLogFile($logJson){
    if([string]::IsNullOrEmpty($PSLogFilePath)){
        Write-Error "Need to set `$PSLogFilePath"
        $logJson
        return
    }

    if(-not(Test-Path $PSLogFilePath)){
        New-Item -ItemType File -Force -Path $PSLogFilePath
    }

    $info = Get-ItemProperty $PSLogFilePath
    
    if($info.Length -gt (50 * 1024 * 1024)){
        _ArchiveLogFile
    }

    # Add-Content sometimes complains about stream not being readable - http://stackoverflow.com/questions/27370389/add-content-produces-stream-not-readable
    [System.IO.File]::AppendAllText($PSLogFilePath, $logJson + [Environment]::NewLine)
}

function Log-Info(){
    param(
    [string]$logMessage,
    [System.Collections.Hashtable]$logProps = @{}
    )

    Write-Host $logMessage
    _WriteToLogFile (_GetJson $logMessage "Info" $logProps)
}

function Log-Warning(){
    param(
    [string]$logMessage,
    [System.Collections.Hashtable]$logProps = @{}
    )

    Write-Warning $logMessage
    _WriteToLogFile (_GetJson $logMessage "Warning" $logProps)
}

function Log-Error(){
    param(
    [string]$logMessage,
    [System.Collections.Hashtable]$logProps = @{}
    )

    Write-Error $logMessage
    _WriteToLogFile (_GetJson $logMessage "Error" $logProps)
}
