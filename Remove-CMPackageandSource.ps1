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