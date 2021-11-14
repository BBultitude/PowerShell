Import-MEMModule A00
function Write-Log
    {param([Parameter(Mandatory=$true)][String]$LogText,[Parameter(Mandatory=$true)]$LogPath,[ValidateSet("Informational","Warning","Error","Verbose")]$LogLevel="Informational",[String]$LogComponent)
    $timeDate = Get-Date -Format MM-dd-yyyy
    $timeTime = Get-Date -Format HH:mm:ss.fff-fff
    switch ($LogLevel)
        {
        "Informational" {"<![LOG[$LogText]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"$LogLevel`: $LogComponent`" type=`"1`">" | Out-File -FilePath $LogPath -Append -Encoding utf8}
        "Warning" {"<![LOG[$LogText]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"$LogLevel`: $LogComponent`" type=`"2`">" | Out-File -FilePath $LogPath -Append -Encoding utf8}
        "Error" {"<![LOG[$LogText]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"$LogLevel`: $LogComponent`" type=`"3`">" | Out-File -FilePath $LogPath -Append -Encoding utf8}
        "Verbose" {"<![LOG[$LogText]LOG]!><time=`"$timetime`" date=`"$timeDate`" component=`"$LogLevel`: $LogComponent`" type=`"4`">" | Out-File -FilePath $LogPath -Append -Encoding utf8}
        }
    }
$logdate = Get-Date -Format MM-dd-yyyy_HHmmss 
$Logfile = "C:\Temp\SMOAR $($logdate).log"
$Counter = 1
$OldRule = "Windows 10"
Write-Log -LogPath $Logfile -LogLevel Informational -LogText "Started process"
$myGC = Get-CMGlobalCondition -Name "Supported Workstation OS x64"
$myRule = New-CMRequirementRuleBooleanValue -GlobalCondition $myGC -Value $true
$ALLAPPLICATIONS = Get-CMApplication -Fast 
Write-Log -LogPath $Logfile -LogLevel Informational -LogText "Found $($ALLAPPLICATIONS.Count) Applications to review"
Foreach ($app in $ALLAPPLICATIONS) {
    $percentComplete = $(($Counter / $ALLAPPLICATIONS.Count) * 100 )
    $Progress = @{
        Activity = "Processing Applications with old deployment type requirements"
        Status = "Processing $Counter of $($ALLAPPLICATIONS.Count)"
        PercentComplete = $([math]::Round($percentComplete, 2))
    }
    Write-Progress @Progress -Id 1
    Write-Log -LogPath $Logfile -LogLevel Informational -LogText "Working with $($app.LocalizedDisplayName)"
    if ($app.IsDeployed -eq $true) {
    Write-Log -LogPath $Logfile -LogLevel Informational -LogText "$($app.LocalizedDisplayName) is deployed"
    $allapp = Get-CMApplication -Name $app.LocalizedDisplayName
    $AllAppMgmt = ([xml]$allapp.SDMPackageXML).AppMgmtDigest
    $DTN = 0
        foreach ($DeploymentType in $AllAppMgmt.DeploymentType) {
            #$DeploymentTypeName = ([xml]$allapp.SDMPackageXML).AppMgmtDigest.DeploymentType[$DTN].Title.'#text'
            $DeploymentTypeName = ([xml]$allapp.SDMPackageXML).AppMgmtDigest.DeploymentType.Title.'#text'
            $DestApplicationName = ([xml]$allapp.SDMPackageXML).AppMgmtDigest.Application.Title.'#text'
            Write-Log -LogPath $Logfile -LogLevel Informational -LogText "Working with $DestApplicationName application and $DeploymentTypeName deployment type"
            #$DestApplicationName = $appname
            $DestApplication = Get-CMApplication -Name ([xml]$allapp.SDMPackageXML).AppMgmtDigest.Application.Title.'#text' | ConvertTo-CMApplication
            Write-Log -LogPath $Logfile -LogLevel Informational -LogText "Converted $DestApplicationName to SDK Object"
            #$Requirements = $DestApplication.DeploymentTypes[$DTN].Requirements | Where-Object { $_.Name -match $OldRule }
            $Requirements = $DestApplication.DeploymentTypes[$DTN].Requirements | Where-Object { $_.Name -match $OldRule -and $_.Name -notmatch "multi-session" -and $_.Name -notmatch "Server" -and $_.Name -notmatch "Embedded" }
            #$Requirements = $DestApplication.DeploymentTypes.Requirements | Where-Object { $_.Name -match $OldRule -and $_.Name -notmatch "multi-session" -and $_.Name -notmatch "Server" -and $_.Name -notmatch "Embedded" }
            $ReqRules = $DestApplication.DeploymentTypes[$DTN].Requirements | Where-Object { $_.Name -match $OldRule -and ($_.Name -match "multi-session" -or $_.Name -match "Server" -or $_.Name -match "Embedded") }
            #$ReqRules = $DestApplication.DeploymentTypes.Requirements | Where-Object { $_.Name -match $OldRule -and ($_.Name -match "multi-session" -or $_.Name -match "Server" -or $_.Name -match "Embedded") }
            #$Response = "NO"
            $Requirements | ForEach-Object {
                if ($Requirements) {
                    Write-Warning "Application: `"$($DestApplicationName)`" and Deployment Type: `"$($DeploymentTypeName)`" contains the rule:

    `"$($_.Name)`""
                    Write-Log -LogPath $Logfile -LogLevel Informational -LogText "Application: `"$($DestApplicationName)`" and Deployment Type: `"$($DeploymentTypeName)`" contains the rule:

    `"$($_.Name)`""
                    #$Response = Read-Host "Do you want to replace this with a new Deployment type? Y/N?"
                    #If ($Response -eq "Y") {
                        $backup = $DestApplication.DeploymentTypes[$DTN].Requirements.Copy()
                        Write-Log -LogPath $Logfile -LogLevel Informational -LogText "Backed up existing requirement rules excluding $oldRule exclusive rules"
                        #$backup = $DestApplication.DeploymentTypes.Requirements.Copy()
                        Write-Warning "The following rule has been deleted:
    `"$($_.Name)`""
                        Write-Log -LogPath $Logfile -LogLevel Informational -LogText "The following rule has been deleted:
    `"$($_.Name)`""
                        $DestApplication.DeploymentTypes[$DTN].Requirements.Clear()
                        Write-Log -LogPath $Logfile -LogLevel Informational -LogText "All requirement rules flushed from deployment type"
                        #$DestApplication.DeploymentTypes.Requirements.Clear()
                        #$newcopy = $backup | Where-Object { $_.Name -notmatch $OldRule }
                        $newcopy = $backup | Where-Object { $_.Name -notmatch $OldRule -or ($_.Name -match "multi-session" -or $_.Name -match "Server" -or $_.Name -match "Embedded") }
                        $newcopy | % { $DestApplication.DeploymentTypes[$DTN].Requirements.Add($_) }
                        Write-Log -LogPath $Logfile -LogLevel Informational -LogText "Imported backed up requirement rules"
                        #$newcopy | % { $DestApplication.DeploymentTypes.Requirements.Add($_) }
                        $CMApplication = ConvertFrom-CMApplication -Application $DestApplication
                        $CMApplication.Put()
                        Write-Log -LogPath $Logfile -LogLevel Informational -LogText "Commited rule changes"
                        Set-CMDeploymentType -ApplicationName $DestApplicationName -DeploymentTypeName $DeploymentTypeName -AddRequirement $myRule
                        Write-Log -LogPath $Logfile -LogLevel Informational -LogText "Added new requirement rule: `"$($myRule.Name)`""
                    #}
                }   
            }
            if (!($Requirements)) {
                Write-Warning "Application: `"$($DestApplicationName)`" and Deployment Type: `"$($DeploymentTypeName)`" contains no rules to auto update please review `"$($ReqRules.Count)`" rules manually"
                Write-Log -LogPath $Logfile -LogLevel Informational -LogText "Application: `"$($DestApplicationName)`" and Deployment Type: `"$($DeploymentTypeName)`" contains no rules to auto update please review `"$($ReqRules.Count)`" rules manually"
             }
            #$DTN ++
        }
    }
    Else {Write-Log -LogPath $Logfile -LogLevel Informational -LogText "$($app.LocalizedDisplayName) is not deployed"}
    $Counter++
}
Write-Log -LogPath $Logfile -LogLevel Informational -LogText "Finished process"

<#
Import-MEMModule A00
$OldRule = "Windows 10"
$myGC = Get-CMGlobalCondition -Name "Supported Workstation OS x64"
$myRule = New-CMRequirementRuleBooleanValue -GlobalCondition $myGC -Value $true
#$appname = "Edge Version 79.0.309.65"
$ALLAPPLICATIONS = Get-CMApplication #-Name $appname

Foreach ($allapp in $ALLAPPLICATIONS) {
    $AllAppMgmt = ([xml]$allapp.SDMPackageXML).AppMgmtDigest
    $DTN = 0
    foreach ($DeploymentType in $AllAppMgmt.DeploymentType) {
        $DeploymentTypeName = ([xml]$allapp.SDMPackageXML).AppMgmtDigest.DeploymentType[$DTN].Title.'#text'
        $DestApplicationName = ([xml]$allapp.SDMPackageXML).AppMgmtDigest.Application.Title.'#text'
        $DestApplication = Get-CMApplication -Name ([xml]$allapp.SDMPackageXML).AppMgmtDigest.Application.Title.'#text' | ConvertTo-CMApplication
        #$Requirements = $DestApplication.DeploymentTypes[$DTN].Requirements | Where-Object { $_.Name -match $OldRule }
        $Requirements = $DestApplication.DeploymentTypes[$DTN].Requirements | Where-Object { $_.Name -match $OldRule -and $_.Name -notmatch "multi-session" -and $_.Name -notmatch "Server" -and $_.Name -notmatch "Embedded" }
        $ReqRules = $DestApplication.DeploymentTypes[$DTN].Requirements | Where-Object { $_.Name -match $OldRule -and ($_.Name -match "multi-session" -or $_.Name -match "Server" -or $_.Name -match "Embedded") }
        $Response = "NO"
        $Requirements | ForEach-Object {
            if ($Requirements) {
                Write-Warning "Application: `"$($DestApplicationName)`" and Deployment Type: `"$($DeploymentTypeName)`" contains the rule:

`"$($_.Name)`""
                $Response = Read-Host "Do you want to replace this with a new Deployment type? Y/N?"
                If ($Response -eq "Y") {
                    $backup = $DestApplication.DeploymentTypes[$DTN].Requirements.Copy()
                    Write-Warning "The following rule has been deleted:
`"$($_.Name)`""
                    $DestApplication.DeploymentTypes[$DTN].Requirements.Clear()
                    #$newcopy = $backup | Where-Object { $_.Name -notmatch $OldRule }
                    $newcopy = $backup | Where-Object { $_.Name -notmatch $OldRule -or ($_.Name -match "multi-session" -or $_.Name -match "Server" -or $_.Name -match "Embedded") }
                    $newcopy | % { $DestApplication.DeploymentTypes[$DTN].Requirements.Add($_) }
                    $CMApplication = ConvertFrom-CMApplication -Application $DestApplication
                    $CMApplication.Put()
                    Set-CMDeploymentType -ApplicationName $DestApplicationName -DeploymentTypeName $DeploymentTypeName -AddRequirement $myRule
                }
            }   
        }
        if (!($Requirements)) { Write-Warning "Application: `"$($DestApplicationName)`" and Deployment Type: `"$($DeploymentTypeName)`" contains no rules to auto update please review `"$($ReqRules.Count)`" rules manually" }
        $DTN ++
    }
}

#>