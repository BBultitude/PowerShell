function Set-CMDriverBiosEnvironment ($OldPackage, $NewPackage) {
    $NewPKG = Get-CMPackage -ID $Newpackage -Fast
    $OldPKG = Get-CMPackage -ID $OldPackage -Fast
    $NewPKGNewname = $NewPKG.Name.Replace("BIOS Update Pilot -", "BIOS Update -")
    $OldPKGNewname = $OldPKG.Name.Replace("BIOS Update -", "BIOS Update Retired -")
    Write-Host "$($NewPKG.name) to be changed to $NewPKGNewName"
    Write-Host "$($OldPKG.name) to be changed to $OLDPKGNewName"
    $Confirm = Read-Host "Are you sure? (Y)es or (N)o"
    If ($Confirm -ieq "Y") {
        Set-Location A00:
        Set-CMPackage -Id $NewPackage -NewName $NewPKGNewname
        Set-CMPackage -Id $OldPackage -NewName $OldPKGNewname
    }
}