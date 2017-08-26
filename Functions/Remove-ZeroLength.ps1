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