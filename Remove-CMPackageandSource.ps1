<#
.SYNOPSIS
    Cleans up Packages
.DESCRIPTION
    Remove-CMPackageandSource removes all specified Packages and the source directory from Configuration Manager
.PARAMETER Packages
    Specifies the Package ID's to be run against
.INPUTS
    None
.OUTPUTS
    None
.NOTES
    Version:        1.1
    Author:         Bryan Bultitude
    Creation Date:  24/08/2021
    Purpose/Change: Added check for content being used by other package or application
.EXAMPLE
    PS> Remove-CMPackageandSource -Packages "XXXXXXX"
.EXAMPLE
    PS> Remove-CMPackageandSource -Packages "XXXXXXX","XXXXXXX","XXXXXXX","XXXXXXX","XXXXXXX","XXXXXXX","XXXXXXX","XXXXXXX"
#>
function Remove-CMPackageandSource ($Packages) {
    Import-CMModule A00
    foreach ($Package in $Packages) {
        $Info = Get-CMPackage -ID $package -Fast
        $Response = Read-Host "$($Info.Name) has a PKG ID of $($Info.PackageID) will be processed... Continue (Y)es / (N)o"
        If ($Response -ieq "Y") {
            $pkgSource = Get-CMPackage -Id $package -Fast | Select-Object Pkgsourcepath
            $pkgSource = $pkgSource.Pkgsourcepath
            $contentlocationcompare = $pkgSource.trimend("\")
    
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
            Write-Host "Source data managed, now deleting applcation from console"
            Remove-CMPackage -Id $package -Force
            Write-Host "$package has been deleted"
        }
        Else { Write-Host "Doing nothing due to response provided" }
                
    }
    
}