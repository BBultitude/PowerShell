function Set-MEMDriverBiosEnvironment {
    <#
    .SYNOPSIS
        Renames Packages to be used with Driver Automation Tool
    .DESCRIPTION
        Set-MEMDriverBiosEnvironment when provided package ID for old and new version of BIOS or Drivers which are created by the Driver Automation Tool it will rename the new package from Pilot to Production and old package from Production to Retired
    .PARAMETER OldPackage
        Specifies the old Package ID to be run against and and rename to Retired
    .PARAMETER NewPackage
        Specifies the new Package ID to be run against and and rename to Prod
    .INPUTS
        None
    .OUTPUTS
        None
    .NOTES
        Version:        1.3
        Author:         Bryan Bultitude
        Creation Date:  24/08/2021
        Purpose/Change: 24/08/2021 - Bryan Bultitude - Initial script development
                        21/09/2021 - Bryan Bultitude - Updated Function name to be different from Configuration Module Functions
                        09/12/2021 - Bryan Bultitude - Moved Comment Based Help to top of function
                        18/02/2022 - Bryan Bultitude - Added functionality to handle multiple packages, removed confirmation and converted from specifying new and old package id's to just a switch between modes
    .EXAMPLE
        PS> Set-MEMDriverBiosEnvironment -PackageIDs "A0000XX","A0000XX","A0000XX","A0000XX" -Mode Promote
        .EXAMPLE
        PS> Set-MEMDriverBiosEnvironment -PackageIDs "A0000XX","A0000XX","A0000XX","A0000XX" -Mode Retire
        .EXAMPLE
        PS> Set-MEMDriverBiosEnvironment -PackageIDs "A0000XX" -Mode Restore
    #>
    param ([Parameter(Mandatory = $True)]$PackageIDs,
        [Parameter(Mandatory = $True)][ValidateSet("Promote", "Retire", "Restore")]$Mode
    )
    Import-MEMModule A00
    
    foreach ($Package in $PackageIDs) {
        $Package = Get-CMPackage -ID $Package -Fast
        IF ($Package.Name -ilike "BIOS *") {
        
            Switch ($Mode) { 
                Promote { $NewPKGNewname = $Package.Name.Replace("BIOS Update Pilot -", "BIOS Update -") }
                Retire { $NewPKGNewname = $Package.Name.Replace("BIOS Update -", "BIOS Update Retired -") }
                Restore { $NewPKGNewname = $Package.Name.Replace("BIOS Update Retired -", "BIOS Update -" ) }
            }
        }
        IF ($Package.Name -ilike "Drivers *") {
        
            Switch ($Mode) { 
                Promote { $NewPKGNewname = $Package.Name.Replace("Drivers Pilot -", "Drivers -") }
                Retire { $NewPKGNewname = $Package.Name.Replace("Drivers -", "Drivers Retired -") }
                Restore { $NewPKGNewname = $Package.Name.Replace("Drivers Retired -", "Drivers -" ) }
            }
        }
        Write-Host "Package `"$($Package.PackageID)`" with a name of `"$($Package.name)`" to be changed to `"$NewPKGNewName`""
        Set-Location A00:
        Set-CMPackage -Id $Package.PackageID -NewName $NewPKGNewname
    }
    Set-Location $env:HOMEDRIVE
}