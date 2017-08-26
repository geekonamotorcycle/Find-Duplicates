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
function Get-HashObject {
    param(
        [AllowEmptyString()]    
        [String]$SourcePath
    )

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
function Remove-ZeroLength {
    param(
        [int]$LengthFilter = 1,
        $ArrayIn
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
    $zLengthArray = @()
    $pLengthArray = @()
    $ArrayIn = Import-Csv -Path .\File_Hash_results.csv
    if ($ArrayIn -ne $null) {
        Write-Host "Found Input Object, Scanning for Zero File Size"
        foreach ($line in $ArrayIn) {
            if ($line.size -le $LengthFilter) {
                $properties = @{Filepath = $line.FilePath; FileHash = $line.FileHash; Size = $line.size}
                $zLength = New-Object -TypeName HashHolder -Property $properties
                $zLengthArray += $zLength
            }
            else {
                $properties = @{FilePath = $line.FilePath; FileHash = $line.FileHash; Size = $line.size; LastModified = $line.LastModified}
                $pLength = New-Object -TypeName HashHolder -Property $properties
                $pLengthArray += $pLength
            }
        }
        $pLengthArray | Export-Csv -Encoding UTF8 -NoTypeInformation -Path pFile_Hash_results.csv
        $zLengthArray | Export-Csv -Encoding UTF8 -NoTypeInformation -Path Zero_Length_Results.csv
    }
}
Function Find-HashMatch {
    $startTime = [datetime]::Now
    $liveObject = @()
    if (Test-Path .\pFile_Hash_results.csv) {
        Write-Host "You are in the right place..."
        $object1 = Import-Csv -Path .\pFile_Hash_results.csv | Sort-Object -Descending
        $object2 = $object1
        #$objectCount = $object1.count
        #$i = 1
        $MatchCount = 0
        foreach ($Hashline in $object2) {
            foreach ($line1 in $object1) {
                $test = $line1.FileHash.equals($Hashline.FileHash)
                if ($test) {
                    #Write-Host "Match Found!" $line1.FullName
                    $MatchCount++
                    if ($MatchCount -gt 2) {
                        $properties = @{FilePath = $HashLine.FilePath; FileHash = $HashLine.FileHash; Size = $Hashline.size; LastModified = $Hashline.LastModified}
                        $properties += @{FilePath2 = $line1.FilePath; FileHash2 = $line1.FileHash; Size2 = $line1.size; LastModified2 = $line1.LastModified}
                        $foundMatches = New-Object HashHolder -Property $properties
                        $liveObject += $foundMatches
                    }
                    #Write-Progress -Activity "Iterating" -Status "Work Work Work, all day long" -PercentComplete ($i / $objectCount * 100) -CurrentOperation "$i / $objectCount"
                    #$i++
                }
            }$MatchCount = 0
        }

        $liveObject | Out-GridView -Title "Matches"
        $liveObject | ConvertTo-Csv -NoTypeInformation > Hash_Match_list.csv
    }
    else {
        Get-HashObject
    }
    $endtime = [datetime]::Now
    $runtime = ($startTime - $endtime)
    Write-Host $runtime
}
#Get-HashObject 
Remove-ZeroLength
Find-HashMatch