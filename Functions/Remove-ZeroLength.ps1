#Remove-ZeroLength 0.8
#Iterates through the input array and seperates files of less than a specified 
#Length out and into a seperate array and then dumps them into a CSV file. 
#<Switches>
#	-LengthFilter, Minimum length a file must be to pass through the seperation
#		Default 1
#	-ArrayIn, the input array, in this script the array comes from 
#		Get-HashObject and is named $liveObject
#	-DumpCSV if $true a CSV of the output object wil be dropped into the same 
#		Folder that the script was run from. Defaults $true
#<Output>
#	Output: $PenultimateTable
#	Output: .\pFile_Hash_results.csv
#	Output: .\zFile_Hash_results.csv
# Copyright 2017 Joshua Porrata, For private use only.

function Remove-ZeroLength {
    param(
        $DumpCSV = $true,
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
    if ($ArrayIn -eq $null) {
        Write-Host "`nInput array is empty Attempting to read 'File_Hash_results.csv', Scanning for Zero File Size`n" -ForegroundColor Yellow
        $ArrayIn = Import-Csv -Path .\File_Hash_results.csv
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
        $pLengthArray | Export-Csv -Encoding UTF8 -NoTypeInformation -Path .\pFile_Hash_results.csv
        $zLengthArray | Export-Csv -Encoding UTF8 -NoTypeInformation -Path .\Zero_Length_Results.csv
    }
    else {
        Write-Host "`nFound Input Array, Scanning for Zero File Size`n" -ForegroundColor Green
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
        if ($dumpCSV) {
            $pLengthArray | Export-Csv -Encoding UTF8 -NoTypeInformation -Path .\pFile_Hash_results.csv
            $zLengthArray | Export-Csv -Encoding UTF8 -NoTypeInformation -Path .\Zero_Length_Results.csv
        }
    }
    $script:PenultimateTable = $pLengthArray
}