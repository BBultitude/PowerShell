<#
.SYNOPSIS
    Renames Packages to be used with Driver Automation Tool
.DESCRIPTION
    Set-CMDriverBiosEnvironment when provided package ID for old and new version of BIOS or Drivers which are created by the Driver Automation Tool it will rename the new package from Pilot to Production and old package from Production to Retired
.PARAMETER OldPackage
    Specifies the old Package ID to be run against and and rename to Retired
.PARAMETER NewPackage
    Specifies the new Package ID to be run against and and rename to Prod
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
    PS> Set-CMDriverBiosEnvironment -OldPackage "XXXXXXX" -NewPackage "XXXXXXX"
#>
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