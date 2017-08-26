function Get-HashObject {
    param(
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
    $infoObject = Get-ChildItem -File -Path "C:\users\joshp\downloads\" -Recurse
    #$ObjectCount = $infoObject.count
    #$i = 1
    foreach ($file in $infoObject) {
        $loopHash = Get-FileHash -Path $file.FullName -Algorithm SHA1
        $loopHash = $loopHash.Hash
        #$properties = @{FilePath = $file.FullName.ToString(); FileHash = $loopHash; Size = $file.Length; LastModified = $file.LastWriteTime}
        $loopObject = New-Object HashHolder -Property @{FilePath = $file.FullName.ToString(); FileHash = $loopHash; Size = $file.Length; LastModified = $file.LastWriteTime} #$properties 
        $liveObject += $loopObject
        #Write-Progress -Activity "Generating File Hashes" -Status "Generating" -PercentComplete ($i / $ObjectCount * 100) -CurrentOperation "$i / $objectCount $loopHash $file"
        #$i++
    }
    $endtime = [datetime]::Now
    $runtime = ($startTime - $endtime)
    Write-Host $runtime
    $liveObject | ConvertTo-Csv -NoTypeInformation > File_Hash_results.csv    
}