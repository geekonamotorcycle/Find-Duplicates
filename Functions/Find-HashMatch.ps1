#Find-HashMatch 
#Makes two copies of the Hahsholder Obect in memory and iterates through them 
#using brute force to find if there is more than one match to a hash. A CSV is 
#written to disk of all matching Hashes 
#<Switches>
#	-DumpCSV if $true a CSV of the output object wil be dropped into the same 
#		Folder that the script was run from. Defaults $true
#	-InputArray The input array to be processed. This comes from 
#		Remove-ZeroLength and is named $PenultimateTable or, if null it will try
#		to find .\pFile_Hash_results.csv and import that.
#	-DisplayOutput, sends the final array to terminal with out-gridview. Be 
#		careful. defaults true.
#<Output>
#	Output: .\Hash_Match_list.csv
#	Output: Out-GridArray to terminal 
# Copyright 2017 Joshua Porrata, For private use only.

Function Find-HashMatch {
    Param(
        $DisplayOutput = $true,    
        $DumpCSV = $true,
        $InputArray
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
    if ($inputArray -eq $null ) {
        if (Test-Path .\pFile_Hash_results.csv) {
            Write-Host "`nThe expected input array was null and could not be processed. " -ForegroundColor Yellow
            Write-Host "Attempting to import .\pFile_Hash_results.csv `n" -ForegroundColor Yellow
            $inputArray = Import-Csv -Path .\pFile_Hash_results.csv | Sort-Object -Descending
        }
        else {
            Write-Host "`nThe expected input array was null and could not be processed. " -ForegroundColor Red
            Write-Host "Attempted to import .\pFile_Hash_results.csv but failed `n" -ForegroundColor Red
        }
       
    }
    else {
        Write-Host "Making Comparisons, Attempting to find matches... This will take some time `n" -ForegroundColor Yellow
        $object1 = $inputArray
        $object2 = $object1
        $MatchCount = 0
        foreach ($Hashline in $object2) {
            foreach ($line1 in $object1) {
                $test = $line1.FileHash.equals($Hashline.FileHash)
                if ($test) {
                    $MatchCount++
                    if ($MatchCount -gt 2) {
                        $properties = @{FilePath = $HashLine.FilePath; FileHash = $HashLine.FileHash; Size = $Hashline.size; LastModified = $Hashline.LastModified}
                        $properties += @{FilePath2 = $line1.FilePath; FileHash2 = $line1.FileHash; Size2 = $line1.size; LastModified2 = $line1.LastModified}
                        $foundMatches = New-Object HashHolder -Property $properties
                        $liveObject += $foundMatches
                    }
                }
            }

        }
        $MatchCount = 0
        if ($DisplayOutput) {   
            $liveObject | Out-GridView -Title "Matches"
        }
        if ($DumpCSV) {
            $liveObject | Export-Csv -Encoding UTF8 -NoTypeInformation -path .\Hash_Match_list.csv
        }
    }
    $endtime = [datetime]::Now
    $runtime = ($startTime - $endtime)
    Write-Host "Matchmaking running time was:" -ForegroundColor Green
    Write-Host $runtime
    Write-Host ""
}