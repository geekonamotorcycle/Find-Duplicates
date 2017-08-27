#Get-HashObject 0.8
#Recurses through a root folder, gathers file information and calculates SHA1 
#Hash Values
#<Switches>
#	-SourcePath Sepcify a root path, this can be manually specified or sent from 
#		$sourcePath from the Read-Paths Function. 
#	-DumpCSV if $true a CSV of the output object wil be dropped into the same 
#		Folder that the script was run from. Defaults $true
#<Outputs>
#	Output: $Script:LiveObject
#	Output: .\File_Hash_results.csv
# Copyright 2017 Joshua Porrata, For private use only.

function Get-HashObject {
    param(
        $DumpCSV = $true,    
        [AllowEmptyString()]    
        [String]$SourcePath
    )
    class HashHolder {
        [string]$FilePath
        [string]$FilePath2
        [string]$FileHash
        [string]$FileHash2
        [int]$Size
        [int]$Size2
        [datetime]$LastModified
        [datetime]$LastModified2
    }

    $startTime = [datetime]::Now
    $liveObject = @()
    $infoObject = Get-ChildItem -File -Path $SourcePath -Recurse
    Write-Host "`nScanning The folder below and generating Hashes`nthis may take some time `n$sourcePath `n" -ForegroundColor Green
    foreach ($file in $infoObject) {
        $loopHash = Get-FileHash -Path $file.FullName -Algorithm SHA1
        $loopHash = $loopHash.Hash
        $loopObject = New-Object HashHolder -Property @{FilePath = $file.FullName.ToString(); FileHash = $loopHash; Size = $file.Length; LastModified = $file.LastWriteTime} #$properties 
        $liveObject += $loopObject
    }
    $endtime = [datetime]::Now
    $runtime = ($startTime - $endtime)
    Write-Host "`nHash Generation took: " -ForegroundColor Green
    Write-Host $runtime 
    $Script:LiveObject = $liveObject 
    if ($DumpCSV) {
        $liveObject | Export-Csv -Encoding UTF8 -NoTypeInformation -path .\File_Hash_results.csv
    } 
}