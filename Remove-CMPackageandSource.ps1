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
    Version:        1.0
    Author:         Bryan Bultitude
    Creation Date:  24/08/2021
    Purpose/Change: Initial script development
.EXAMPLE
    PS> Remove-CMPackageandSource -Packages "XXXXXXX"
.EXAMPLE
    PS> Remove-CMPackageandSource -Packages "XXXXXXX","XXXXXXX","XXXXXXX","XXXXXXX","XXXXXXX","XXXXXXX","XXXXXXX","XXXXXXX"
#>
function Remove-CMPackageandSource ($Packages) {
    foreach ($Package in $Packages) {
        $Info = Get-CMPackage -ID $package -Fast | Select-Object Name, PackageID, Pkgsourcepath | Format-List
        $Info
        $Confirm = Read-Host "Are you sure? (Y)es or (N)o"
        If ($Confirm -ieq "Y") {
            $pkgSource = Get-CMPackage -Id $package -Fast | Select-Object Pkgsourcepath
            $pkgSource = $pkgSource.Pkgsourcepath
            $pkgSource = $pkgSource.trimend("\")
            Set-Location C:
            Remove-Item -path $pkgSource -Recurse
            Set-Location A00:
            Remove-CMPackage -Id $package -Force
        }
    }
}