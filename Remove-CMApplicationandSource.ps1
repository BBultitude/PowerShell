function Remove-CMApplicationandSource ($ApplicationName) {
    Import-CMModule A00
    $Application = Get-CMApplication -Name $ApplicationName
    $PKGID = $Application.PackageID
    $Replaced = $Application.IsSuperseded
    $Replacing = $Application.IsSuperseding
    $Deployed = $Application.NumberOfDeployments
    $TaskSequence = $Application.NumberOfDependentTS
    if (($Replacing -eq $False) -and ($Replaced -eq $false) -and ($Deployed -eq 0) -and ($TaskSequence -eq 0)) {
        Write-Host "$ApplicationName is not Superseded or Superseding."
        $Response = Read-Host "$ApplicationName has a PKG ID of $PKGID will be processed... Continue (Y)es / (N)o"
        If ($Response -ieq "Y") {
            $ContentLocation = @{}
            $AppMgmt = ([xml]$Application.SDMPackageXML).AppMgmtDigest
            foreach ($DeploymentType in $AppMgmt.DeploymentType) {
                $ContentLocation.Add($DeploymentType.Title.InnerText, $DeploymentType.Installer.Contents.Content.Location)
            }
            If ($Application.HasContent -eq $true) {
                $uniqueContentlocal = $ContentLocation.Values | Select-Object -Unique
                $contentlocationcompare = $uniqueContentlocal.TrimEnd('\')
                Write-Host "Checking source against all applications to confirm its unique... This will take some time"
                ForEach ($contentlocal in $uniqueContentlocal) {
                    $ALLAPPLICATIONS = Get-CMApplication | Where-Object { $_.ci_ID -ne $contentidcompare }
                    $AllAppscontent = @{}
                    Foreach ($allapp in $ALLAPPLICATIONS) {
                        $AllAppMgmt = ([xml]$allapp.SDMPackageXML).AppMgmtDigest
                        foreach ($DeploymentType in $AllAppMgmt.DeploymentType) {
                            $AllAppscontent.Add("$($Allapp.CI_ID) - $($DeploymentType.Title.InnerText)", $DeploymentType.Installer.Contents.Content.Location)
                        }
                    }
                    $CMPackages = Get-CMPackage -Fast
                    Foreach ($PKGInfo in $CMPackages) {
                        $AllAppscontent.Add($PKGInfo.PackageID, $($PKGInfo.PkgSourcePath).TrimEnd('\'))
                    }
                    $uniqueContent = $true
                    foreach ($h in $AllAppscontent.Keys) {
                        if ($($AllAppscontent.Item($h)) -ne $null) {
                            $comparison = Compare-object -DifferenceObject $($AllAppscontent.Item($h)) -ReferenceObject $contentlocationcompare -IncludeEqual -ExcludeDifferent
                            if ($comparison.sideindicator -eq "==") {
                                If (${h} -notmatch $contentidcompare) {
                                    Write-Host "Content is used elsewhere only Application can be deleted"
                                    $uniqueContent = $false
                                }
                            }
                        }
                    }
                    If ($uniqueContent -eq $true) {
                    
                        Write-Host "Deleting Source data"
                        Set-Location C:
                        Remove-Item $ContentLocal -Recurse
                        Set-Location A00:
                    }
                }
                Write-Host "Source data managed, now deleting applcation from console"
                Remove-CMApplication -Id $($Application.CI_ID) -Force
                Write-Host "$ApplicationName has been deleted"
            }
            Else {
                $SecondConf = Read-Host "Do you still want to delete $applicationname as there is no content (Y)es / (N)o"
                if ($SecondConf -ieq "Y") {
                    Remove-CMApplication -Id $($Application.CI_ID) -Force
                    Write-Host "$ApplicationName has been deleted" 
                }
                else { Write-Host "Doing nothing due to response provided" }
            }
        }
        Else { Write-Host "Doing nothing due to response provided" }
    }
    Else {
        Write-host "$ApplicationName will not be proceessed due to below status:
Superseded $Replaced
Superseding $Replacing
Deployed $Deployed times
Used in $TaskSequence Task Sequences"
    }
}