# Find-duplicates 
# Version 1.0
# Designed for powershell 5.1
# Copyright 2017 - Joshua Porrata
# Not for business use without an inexpensive license, contact
# Localbeautytampabay@gmail.com for questions about a lisence 
# there is no warranty, this might destroy everything it touches. 

#class HashHolder {
#    [string]$FilePath
#    [string]$FilePath2
#    [string]$FileHash
#    [string]$FileHash2
#    [int]$Size
#    [int]$Size2
#    [datetime]$LastModified
#    [datetime]$LastModified2
#}
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
Function Copyright {
    Write-Host "`n***********************************************" -BackgroundColor Black -ForegroundColor DarkGreen
    Write-Host "***Copyright 2017, Joshua Porrata**************" -BackgroundColor Black -ForegroundColor DarkGreen
    Write-Host "***This program is not free for business use***" -BackgroundColor Black -ForegroundColor DarkGreen
    Write-Host "***Contact me at localbeautytampabay@gmail.com*" -BackgroundColor Black -ForegroundColor DarkGreen
    Write-Host "***for a cheap business license****************" -BackgroundColor Black -ForegroundColor DarkGreen
    Write-Host "***Donations are wholeheartedly accepted ******" -BackgroundColor Black -ForegroundColor Red
    Write-Host "***accepted @ www.paypal.me/lbtpa**************" -BackgroundColor Black -ForegroundColor Red
    Write-Host "***********************************************`n" -BackgroundColor Black -ForegroundColor DarkGreen
}

#Read-paths 1.1
#grabs the source and destination root Paths and checks that they 
#exist before Passing them on.
#<Switches>
#	-Source will specify a source path Make sure its valid!
#	-Destination will specify a destination path Make sure its valid!
#	-findDestPath if $true, will ask for the destination Folder defualt $true
#<Outputs>
#	Output: $sourcePath the root of the folder we will be scanning.
#	OutPut: $destPath The root of the folder files will be headed to 
#Copyright 2017 Joshua Porrata, For private use only.
Function Read-Paths {
    Param
    (
        [Parameter(Mandatory = $False)]
        [AllowEmptyString()]
        $Source,
        [Parameter(Mandatory = $False)]
        [AllowEmptyString()]
        $findDestPath = $true,
        [Parameter(Mandatory = $False)]
        [AllowEmptyString()]
        $Destination
    )
 

    #Source logic
    if ($source -ne $null) {
        $testSource = Test-Path $Source
        Write-Host "Source: $testsource`n"
        $script:sourcePath = $Source
    }
    elseif ($source -eq $null) {
        $i = 1
        [boolean]$sourcePrompt = $true

        while ($sourcePrompt) {
            Write-Host "Enter Source Path [Attempt $i/3]" -ForegroundColor Green
            $inputSource = Read-Host  -ErrorAction 'SilentlyContinue' -InformationAction 'SilentlyContinue'
            $iSourceTest = Test-Path $inputSource 
            if ($iSourceTest) {
                Write-Host "The source path you entered Passed`n" -ForegroundColor Green
                $script:sourcePath = $inputSource
                $sourcePrompt = $False
            }
            else {
                $i++        
                Write-Host "The path could not be validated `n" -ForegroundColor Red
            }
            if ($i -gt 3) {
                write-host "Too Many Attempts, Contact your Systems Adminstrator for help" -ForegroundColor Red
                $script:runScript = $False
                exit
            }
        }
    }
            
    If ($findDestPath) { 
        #Destination Logic
        If ($destination -ne $null) {
            $testdest = Test-Path $Destination
            Write-Host "Destination: $testDest`n"
            $script:destPath = $Destination
        }
        elseif ($Destination -eq $null) {
            [boolean]$destPrompt = $true
            $i = 1
            while ($destPrompt) {
                Write-Host "Enter Destination Path [Attempt $i/3]" -ForegroundColor Green
                $inputDest = Read-Host 
                $iDestTest = Test-Path -path $inputDest -ErrorAction 'SilentlyContinue'
                if ($iDestTest) {
                    Write-Host "The Destination Path you entered Passed`n" -ForegroundColor Green
                    $script:destPath = $inputDest
                    $destPrompt = $False
                }
                else {
                    $i++        
                    Write-Host "The path could not be validated `n" -ForegroundColor Red
                }
                if ($i -gt 3) {
                    write-host "Too Many Attempts, Contact your Systems Adminstrator for help" -ForegroundColor Red
                    $script:runScript = $False
                    exit
                }
            }
        }
    }
}

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

#Find-HashMatch 0.8
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

Clear-Host
Copyright
Read-Paths -findDestPath $false 
Get-HashObject -SourcePath $sourcePath -DumpCSV $true
Remove-ZeroLength -ArrayIn $liveObject -LengthFilter 1 -DumpCSV $true
Find-HashMatch -InputArray $PenultimateTable -DumpCSV $true -DisplayOutput $

<#
Default Execution Order.

Clear-Host
Copyright
Read-Paths -findDestPath $false  
Get-HashObject -SourcePath $sourcePath -DumpCSV $true
Remove-ZeroLength -ArrayIn $liveObject -LengthFilter 1 -DumpCSV $true
Find-HashMatch -InputArray $PenultimateTable -DumpCSV $true -DisplayOutput $true
#>