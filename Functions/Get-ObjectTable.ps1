Function Get-ObjectTable {
    Param(
        [Parameter(Mandatory = $false)]
        $getSourceHash = $false,
        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [string]$fileTypeFilter,
        [Parameter(Mandatory = $True)]
        [string]$ScanPath
    )
 
    $i = 1
    $time = Get-Date
    $scanObject = @()

    #First, use get-childitems using $Script:sourcePath from Read-paths function to enumerate all of the objects in the table
    Write-Host "`Looking for files in`n$ScanPath"
    $sourceObject = Get-ChildItem  -recurse -File -Path $ScanPath 

    #Second-Check if the source path is empty, if it is break the script. 
    $sourceCount = $sourceObject.count
    If ($sourceCount -eq 0) {
        write-host "Source Path is empty." -ForegroundColor red
        $Script:runscript = $false
        exit
    }
    Write-Host "`nExtracting File details and sorting..`n" -ForegroundColor green
    #third for each item, select just the required propteries
    foreach ($File in $sourceObject) {
        $cDateToString = $file.CreationTime
        $cDateToShort = $cDateToString.ToShortDateString()
        $cDateFormated = $cDateToShort.replace('/', '-')
        #Include: CreationTime, FileName, Size, FileType, FullPath.
        $LoopObject = New-Object PSObject @()
        $LoopObject | Add-Member -MemberType NoteProperty -Name "CreationTime" -Value $file.CreationTime -ErrorVariable $ObjectTableError
        $LoopObject | Add-Member -MemberType NoteProperty -Name "CDate" -Value $cDateFormated -ErrorVariable $ObjectTableError
        $LoopObject | Add-Member -MemberType NoteProperty -Name "FileName" -Value $file.name -ErrorVariable $ObjectTableError
        $LoopObject | Add-Member -MemberType NoteProperty -Name "Size" -Value $file.Length -ErrorVariable $ObjectTableError
        $LoopObject | Add-Member -MemberType NoteProperty -Name "FileType" -Value $file.extension -ErrorVariable $ObjectTableError
        $LoopObject | Add-Member -MemberType NoteProperty -Name "FullPath" -Value $file.FullName -ErrorVariable $ObjectTableError
        #include: If (getSourceHash - eq $true)Then Get the file Hash and add it, if $false then output "NotCalculated"
        If ($getSourceHash) {
            $fileHash = Get-FileHash -Path $File.FullName -Algorithm SHA1 -ErrorVariable $hasherror
            $LoopObject | Add-Member -MemberType NoteProperty -Name "Hash" -Value $fileHash.Hash -ErrorVariable $ObjectTableError
        }
        Else {
            $LoopObject | Add-Member -MemberType NoteProperty -Name "Hash" -Value "NotCalculated" -ErrorVariable $ObjectTableError
        }
        #Include: ScriptTime
        $LoopObject | Add-Member -MemberType NoteProperty -Name "LoopTime" -Value $time -ErrorVariable $ObjectTableError
        #Add them to a loop collector
        $scanObject += $LoopObject
    
        If ($watchWork) {
            Write-Progress -Activity "Scanning Objects " -status "Scanned $i of $sourceCount "  -percentComplete ($i / $sourceCount) -ErrorVariable $progressError
        }
        $i++
    }
    #Have the loop collectory select only unique filenames. I know its inelegant, but it will prevent writing over objects
    $scanObject = $scanObject | Sort-Object filename -Unique -Descending
    
    
    #Output $Script:directoryObject For the Move-Objects  function
    $script:directoryObject = $scanObject 
    if ($scanObject -ne $null) {
       
        $creationTimesObject = $scanobject.CreationTime
        Write-Host "Selecting files by creation time 1/4" -ForegroundColor Green
        $shortDateString = $creationTimesObject.ToShortDateString()
        Write-Host "Converting to String 2/4" -ForegroundColor Green
        $uniqueStrings = $shortDateString | Select-Object -Unique
        Write-Host "Selecting only unique Dates 3/4" -ForegroundColor Green
        $script:uniquedays = $uniqueStrings.replace('/', '-')
        Write-Host "Creating names compatible with Windows File system 4/4 `n" -ForegroundColor Green
    }
    else {
        Write-Host "Something has gone wrong, while scanning for unique dates a null object was found. Exiting Script" -ForegroundColor Red
        $Script:runscript = $false
        Exit
    }
}
#testing stuff Below Here
Get-ObjectTable -ScanPath "C:\unsorte"
$directoryObject | Out-GridView
$uniquedays | Out-GridView