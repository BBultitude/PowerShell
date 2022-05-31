function Find-MEMDevice {
    <#
    .SYNOPSIS
       Find a computer in Configuration Manager
    .DESCRIPTION
       Find a computer in Configuration Manager based on Device Name, User Name, MAC Address or get a count of devices with specific OS version
    .PARAMETER Computer
       Define the computer name to search for
    .PARAMETER User
       Define the user name to search for. eg BRYBUL1
    .PARAMETER MAC
       Define the MAC Address to search for. Formats that are accepted are:
       XX:XX:XX:XX:XX:XX
       XX-XX-XX-XX-XX-XX
       XX XX XX XX XX XX
       XX.XX.XX.XX.XX.XX
       XXXX:XXXX:XXXX
       XXXX-XXXX-XXXX
       XXXX XXXX XXXX
       XXXX.XXXX.XXXX
       XXXXXXXXXXXX
    .PARAMETER CountOSVersion
       Defines the OS to search for. This is a predefined list
    .INPUTS
       N/A
    .OUTPUTS
       N/A
    .NOTES
       Version:        1.1
       Author:         Bryan Bultitude
       Creation Date:  27/04/2022
       Purpose/Change: 27/04/2022 - Bryan Bultitude - Initial script development
                       11/05/2022 - Bryan Bultitude - Simplified MAC address conversion, removed Dynamic Parameters, added ability to get Users Name, Title and convert OS version to friendly name
                       31/05/2022 - Bryan Bultitude - Converted parameters to use ParameterSetName to limit options once something is already selected
    .EXAMPLE
       PS> Find-MEMDevice -Computer BBWIN10-01
    .EXAMPLE
       PS> Find-MEMDevice -User BRYTES1
    .EXAMPLE
       PS> Find-MEMDevice -MAC XX:XX:XX:XX:XX:XX
    .EXAMPLE
       PS> Find-MEMDevice -CountOSVersion 'Win10 - 1507'
    #>
    param (
        [Parameter(Mandatory = $True, ParameterSetName = 'Computer')]
        $Computer = "",
        [Parameter(Mandatory = $True, ParameterSetName = 'User')]
        $User = "",
        [Parameter(Mandatory = $True, ParameterSetName = 'MAC')]
        $MAC = "",
        [Parameter(Mandatory = $True, ParameterSetName = 'OS')]
        [ValidateSet("Win10 - 1507", "Win10 - 1511", "Win10 - 1607", "Win10 - 1703", "Win10 - 1709", "Win10 - 1803", "Win10 - 1809", "Win10 - 1903", "Win10 - 1909", "Win10 - 20H1", "Win10 - 20H2", "Win10 - 21H1", "Win10 - 21H2", "Win11 - 21H2")]
        $CountOSVersion = ""
    )
    Import-MEMModule A00
    If ($Computer -ne "") {
        $Devices = Get-CMDevice | Where-Object { $_.Name -eq $Computer } 
    }
    elseif ($User -ne "") {
        $Devices = Get-CMDevice | Where-Object { $_.UserName -eq $User } 
    }
    elseif ($MAC -ne "") {
        $SupportedPattern = "(([0-9A-Fa-f]{2}[-. :]){5}[0-9A-Fa-f]{2})|(([0-9A-Fa-f]{4}[-: .]){2}[0-9A-Fa-f]{4})|[0-9A-Fa-f]{12}"
        $PaterntoConvert = "(([0-9A-Fa-f]{2}[-. ]){5}[0-9A-Fa-f]{2})|(([0-9A-Fa-f]{4}[-: .]){2}[0-9A-Fa-f]{4})|[0-9A-Fa-f]{12}"
        If ($MAC -match $SupportedPattern) {
            If ($MAC -match $PaterntoConvert) {
                Write-Host "$MAC needs to be converted"
                $MAC = $MAC.Replace("-", "").replace(".", "").replace(" ", "").replace("-", "").replace(":", "")
                $MAC = $MAC -split '(..)' -ne '' -join ':'
            }
        }
        elseif ($MAC -notmatch $SupportedPattern) {
            Write-Host "$MAC is not a valid MAC Address"
        }
        $Devices = Get-CMDevice | Where-Object { $_.MACAddress -match $MAC }
    }
    elseif ($CountOSVersion -ne "") {
        Write-Host "Total devices running $CountOSVersion`:"
        Switch ($CountOSVersion) {
            "Win10 - 1507" { (Get-CMDevice | Where-Object { $_.DeviceOSBuild -like "10.0.10240.*" }).Count }
            "Win10 - 1511" { (Get-CMDevice | Where-Object { $_.DeviceOSBuild -like "10.0.10586.*" }).Count }
            "Win10 - 1607" { (Get-CMDevice | Where-Object { $_.DeviceOSBuild -like "10.0.14393.*" }).Count }
            "Win10 - 1703" { (Get-CMDevice | Where-Object { $_.DeviceOSBuild -like "10.0.15063.*" }).Count }
            "Win10 - 1709" { (Get-CMDevice | Where-Object { $_.DeviceOSBuild -like "10.0.16299.*" }).Count }
            "Win10 - 1803" { (Get-CMDevice | Where-Object { $_.DeviceOSBuild -like "10.0.17134.*" }).Count }
            "Win10 - 1809" { (Get-CMDevice | Where-Object { $_.DeviceOSBuild -like "10.0.17763.*" }).Count }
            "Win10 - 1903" { (Get-CMDevice | Where-Object { $_.DeviceOSBuild -like "10.0.18362.*" }).Count }
            "Win10 - 1909" { (Get-CMDevice | Where-Object { $_.DeviceOSBuild -like "10.0.18363.*" }).Count }
            "Win10 - 20H1" { (Get-CMDevice | Where-Object { $_.DeviceOSBuild -like "10.0.19041.*" }).Count }
            "Win10 - 20H2" { (Get-CMDevice | Where-Object { $_.DeviceOSBuild -like "10.0.19042.*" }).Count }
            "Win10 - 21H1" { (Get-CMDevice | Where-Object { $_.DeviceOSBuild -like "10.0.19043.*" }).Count }
            "Win10 - 21H2" { (Get-CMDevice | Where-Object { $_.DeviceOSBuild -like "10.0.19044.*" }).Count }
            "Win11 - 21H2" { (Get-CMDevice | Where-Object { $_.DeviceOSBuild -like "10.0.22000.*" }).Count }
        }
    }
    if (($Computer -ne "") -or ($User -ne "") -or ($MAC -ne "")) {
        $Results = @()
        $User = Get-ADUser -Properties Title, displayname -Identity $($Devices.username | Select-Object -Unique)
        foreach ($Device in $Devices) {
            switch ($Device.DeviceOSBuild) {
                { $_ -match '10.0.10240.*' } { $OSFriendlyName = "Win10 - 1507" }
                { $_ -match '10.0.10586.*' } { $OSFriendlyName = "Win10 - 1511" }
                { $_ -match '10.0.14393.*' } { $OSFriendlyName = "Win10 - 1607" }
                { $_ -match '10.0.15063.*' } { $OSFriendlyName = "Win10 - 1703" }
                { $_ -match '10.0.16299.*' } { $OSFriendlyName = "Win10 - 1709" }
                { $_ -match '10.0.17134.*' } { $OSFriendlyName = "Win10 - 1803" }
                { $_ -match '10.0.17763.*' } { $OSFriendlyName = "Win10 - 1809" }
                { $_ -match '10.0.18362.*' } { $OSFriendlyName = "Win10 - 1903" }
                { $_ -match '10.0.18363.*' } { $OSFriendlyName = "Win10 - 1909" }
                { $_ -match '10.0.19041.*' } { $OSFriendlyName = "Win10 - 20H1" }
                { $_ -match '10.0.19042.*' } { $OSFriendlyName = "Win10 - 20H2" }
                { $_ -match '10.0.19043.*' } { $OSFriendlyName = "Win10 - 21H1" }
                { $_ -match '10.0.19044.*' } { $OSFriendlyName = "Win10 - 21H2" }
                { $_ -match '10.0.22000.*' } { $OSFriendlyName = "Win11 - 21H2" }
            }
            $Result = [PSCustomObject]@{"Full Name" = $User.DisplayName; "Title" = $User.Title; "Username" = $Device.UserName; "Computer Name" = $Device.Name; "Computer Primary Users" = $device.PrimaryUser; "MAC Address" = $device.MACAddress; "AD Site" = $Device.ADSiteName; "Boundary Groups" = $Device.BoundaryGroups; "ConfigMGR Agent Version" = $device.ClientVersion; "Operating System" = $OSFriendlyName }
            $Results += $Result
        }
        Return $Results
    }
}