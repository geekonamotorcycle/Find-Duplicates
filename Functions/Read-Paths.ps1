Function Read-Paths {
    Param
    (
        [Parameter(Mandatory = $False)]
        [AllowEmptyString()]
        $Source,
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

#testing stuff down here
Read-Paths -Source c:\unsorte # -Destination c:\tes
Write-Host "$Sourcepath"
Write-Host "$destPath"