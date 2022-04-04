function Remove-MEMPackageandSource ($Packages) {
    <#
    .SYNOPSIS
        Cleans up Packages
    .DESCRIPTION
        Remove-MEMPackageandSource removes all specified Packages and the source directory from Configuration Manager
    .PARAMETER Packages
        Specifies the Package ID's to be run against
    .INPUTS
        None
    .OUTPUTS
        None
    .NOTES
        Version:        1.4
        Author:         Bryan Bultitude
        Creation Date:  24/08/2021
        Purpose/Change: 24/08/2021 - Bryan Bultitude - Initial script development
                        25/08/2021 - Bryan Bultitude - Added check for content being used by other package or application
                        21/09/2021 - Bryan Bultitude - Updated Function name to be different from Configuration Module Functions
                        09/12/2021 - Bryan Bultitude - Moved Comment Based Help to top of function
                        04/03/2022 - Bryan Bultitude - Streamlined to ask only once for all packages instead of per package added process bar
    .EXAMPLE
        PS> Remove-MEMPackageandSource -Packages "XXXXXXX"
    .EXAMPLE
        PS> Remove-MEMPackageandSource -Packages "XXXXXXX","XXXXXXX","XXXXXXX","XXXXXXX","XXXXXXX","XXXXXXX","XXXXXXX","XXXXXXX"
    #>
    Import-MEMModule A00
    $x = $Packages.Count
    $i = 0
    foreach ($Package in $Packages) {
        $Info = Get-CMPackage -ID $package -Fast
        Write-Host "$($Info.PackageID) - $($Info.Name)"
    }
    Write-Host
    $Response = Read-Host "Are you sure you want to delete the above packages will be processed... Continue (Y)es / (N)o"
    foreach ($Package in $Packages) {
        $i += 0.25
        Write-Progress -activity "Cleaning up Package and Source Content" -status "Progress: " -PercentComplete (($i / $x) * 100)
        $Info = Get-CMPackage -ID $package -Fast
        If ($Response -ieq "Y") {
            $pkgSource = Get-CMPackage -Id $package -Fast | Select-Object Pkgsourcepath
            $pkgSource = $pkgSource.Pkgsourcepath
            $contentlocationcompare = $pkgSource.trimend("\")
            Write-Host
            Write-Host "Processing $($Info.PackageID) - $($Info.Name)"
            Write-Host "Checking source against all applications to confirm its unique... This will take some time"
            $ALLAPPLICATIONS = Get-CMApplication
            $AllAppscontent = @{}
            Foreach ($allapp in $ALLAPPLICATIONS) {
                $AllAppMgmt = ([xml]$allapp.SDMPackageXML).AppMgmtDigest
                foreach ($DeploymentType in $AllAppMgmt.DeploymentType) {
                    $AllAppscontent.Add("$($Allapp.CI_ID) - $($DeploymentType.Title.InnerText)", $DeploymentType.Installer.Contents.Content.Location)
                }
            }
            $CMPackages = Get-CMPackage -Fast | Where-Object { $_.PackageID -ne $Package }
            Foreach ($PKGInfo in $CMPackages) {
                $AllAppscontent.Add($PKGInfo.PackageID, $($PKGInfo.PkgSourcePath).TrimEnd('\'))
            }
            $i += 0.25
            Write-Progress -activity "Cleaning up Package and Source Content" -status "Progress: " -PercentComplete (($i / $x) * 100)
            $uniqueContent = $true
            foreach ($h in $AllAppscontent.Keys) {
                if ($($AllAppscontent.Item($h)) -ne $null) {
                    $comparison = Compare-object -DifferenceObject $($AllAppscontent.Item($h)) -ReferenceObject $contentlocationcompare -IncludeEqual -ExcludeDifferent
                    if ($comparison.sideindicator -eq "==") {
                        If (${h} -notmatch $package) {
                            Write-Host "Content is used elsewhere only Application can be deleted"
                            $uniqueContent = $false
                        }
                    }
                }
            }
            If ($uniqueContent -eq $true) {
                
                Write-Host "Deleting Source data"
                Set-Location C:
                Remove-Item $contentlocationcompare -Recurse
                Set-Location A00:
            }
            $i += 0.25
            Write-Progress -activity "Cleaning up Package and Source Content" -status "Progress: " -PercentComplete (($i / $x) * 100)
            Write-Host "Source data managed, now deleting applcation from console"
            Remove-CMPackage -Id $package -Force
            Write-Host "$package has been deleted"
            $i += 0.25
            Write-Progress -activity "Cleaning up Package and Source Content" -status "Progress: " -PercentComplete (($i / $x) * 100)
        }
        Else { Write-Host "Doing nothing due to response provided" }
                
    }
    Set-Location $env:HOMEDRIVE        
}