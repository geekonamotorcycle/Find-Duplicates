Function Find-HashMatch {
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