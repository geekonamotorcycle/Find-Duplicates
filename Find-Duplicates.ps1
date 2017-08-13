# Copyright Joshua Porrata 2017
# License: Not free for Business
#
# If you are a individual at home using this for personal things, thats fine, 
# modify it and do what you want, but dont resell it. You should however include 
# this link for donations https://www.paypal.me/lbtpa and the copyright should be 
# displayed when the script is run to remind you that im in poverty and need money.
#
# If you are a sysadmin at a business or some person at a business; you need to 
# contact me for an inexpensive license.  localbeautytampabay@gmail.com

#test Change
$ReadPaths = $true

function readPaths {
    if ($ReadPaths -eq $true) {	
        $inputcount = 1
        while (-not ($testReadPath -and $testReadDestPath)) {
            #enter source path
            $sourcePath = Read-Host "`nEnter the Source Path[attempt #$inputcount] " 
            $testReadPath = Test-Path $sourcepath 
            #varies output based on whether the path exists or not
            if ($testReadPath) {
                Write-Host "You entered: $sourcepath  `nDoes the path exist? $testReadPath" -ForegroundColor Green
            }
            else {
                Write-Host "You entered: $sourcepath  `nDoes the path exist? $testReadPath"	-ForegroundColor Red
            }
            #Enter Destination Path
            $destPath = Read-Host "`nEnter the Destination Path[attempt #$inputcount] " 
            $testReadDestPath = Test-Path $destPath
            if ($testReadDestPath) {	
                Write-Host "You entered: $destPath  `nDoes the path exist? $testReadDestPath" -ForegroundColor Green
            }
            else {
                Write-Host "You entered: $destPath  `nDoes the path exist? $testReadDestPath" -ForegroundColor Red
            }
            Write-Host "`nThe script will pause for 2 seconds now.`nif you are caught in a loop, take this opportunity to `nsend a break command`n" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            $inputcount++
        }
        if ($sourcePath -ne $null) {
            $directoryInfo = Get-ChildItem -Path $sourcePath -Recurse -file
            $fileCount = $directoryInfo.Count
            Write-Host "I found $fileCount files." -ForegroundColor Green
            If ($directoryInfo -eq $null) {
                Write-Host "`nThe source directory you entered was `n" -ForegroundColor Red
                Write-Host "$sourcePath `n" -ForegroundColor Red
                Write-Host "The Source Directory is empty. `nI will break the script; check the directory and ensure there are files for me to sort." -ForegroundColor Red
                Break
            }
        }    
    }
    return $sourcePath
    return $destPath
    return $directoryInfo
}   
Function copyright {
    Write-Host "`n***********************************************" -BackgroundColor Black -ForegroundColor DarkGreen
    Write-Host "***Copyright 2017, Joshua Porrata**************" -BackgroundColor Black -ForegroundColor DarkGreen
    Write-Host "***This program is not free for business use***" -BackgroundColor Black -ForegroundColor DarkGreen
    Write-Host "***Contact me at localbeautytampabay@gmail.com*" -BackgroundColor Black -ForegroundColor DarkGreen
    Write-Host "***for a cheap business license****************" -BackgroundColor Black -ForegroundColor DarkGreen
    Write-Host "***Donations are wholeheartedly accepted ******" -BackgroundColor Black -ForegroundColor Red
    Write-Host "***accepted @ www.paypal.me/lbtpa**************" -BackgroundColor Black -ForegroundColor Red
    Write-Host "***********************************************`n" -BackgroundColor Black -ForegroundColor DarkGreen
}
function GreenText ([string]$textOut) {
    Write-Host "$textOut" -ForegroundColor Green
}

Clear-Host
copyright
GreenText("This application requires two inputs, a source path and a destination path")
GreenText("The application will recurse through the source path gathering file paths and names.")
GreenText("It will then calculate hashes for each file and compare those hashes to each other")
GreenText("If duplicates are found they will be MOVED to a directory by date with unique names")
GreenText("You may then Delete whichever file you dont want and run my movepics script to get ")
GreenText("them organized.")
GreenText("`nI know this script is useful to you,so go ahead and make a donation!`n")
#GreenText("")
 
readPaths
