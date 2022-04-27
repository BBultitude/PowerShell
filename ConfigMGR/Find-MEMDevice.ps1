function Find-MEMDevice {
    <#
    .SYNOPSIS
       Find a computer in Configuration Manager
    .DESCRIPTION
       Find a computer in Configuration Manager based on Device Name, User Name, MAC Address or get a count of devices with specific OS version
    .PARAMETER Computer
       Switches to Computer name search
    .PARAMETER ComputerName
       Define the computer name to search for
    .PARAMETER User
       Switches to User name search
    .PARAMETER UserName
       Define the user name to search for. eg BRYBUL1
    .PARAMETER MAC
       Switches to MAC Address search
    .PARAMETER MACAddress
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
       Switches to count systems with specific OS version
    .PARAMETER OS
       Defines the OS to search for. This is a predefined list
    .INPUTS
       N/A
    .OUTPUTS
       N/A
    .NOTES
       Version:        1.0
       Author:         Bryan Bultitude
       Creation Date:  27/04/2022
       Purpose/Change: 27/04/2022 - Bryan Bultitude - Initial script development
    .EXAMPLE
       PS> Find-MEMDevice -Computer -ComputerName BBWIN10-01
    .EXAMPLE
       PS> Find-MEMDevice -User -UserName BRYTES1
    .EXAMPLE
       PS> Find-MEMDevice -MAC -MACAddress XX:XX:XX:XX:XX:XX
    .EXAMPLE
       PS> Find-MEMDevice -CountOSVersion -OS 'Win10 - 1507'
    #>
    param (
        [Parameter(Mandatory = $false)]
        [Switch]$Computer,
        [Parameter(Mandatory = $false)]
        [Switch]$User,
        [Parameter(Mandatory = $false)]
        [Switch]$MAC,
        [Parameter(Mandatory = $false)]
        [Switch]$CountOSVersion
    )
    DynamicParam {
        $DynamicParam = New-Object System.Management.Automation.ParameterAttribute
        $DynamicParam.Mandatory = $true
        #create an attributecollection object for the attribute we just created.
        $attributeCollection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
        #add our custom attribute
        $attributeCollection.Add($DynamicParam)
        if ($Computer) {
            #add our paramater specifying the attribute collection
            $ComputerNameParam = New-Object System.Management.Automation.RuntimeDefinedParameter('ComputerName', [String], $attributeCollection)
            #expose the name of our parameter
            $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add('ComputerName', $ComputerNameParam)
            return $paramDictionary
        }
        if ($User) {
            #add our paramater specifying the attribute collection
            $UserNameParam = New-Object System.Management.Automation.RuntimeDefinedParameter('UserName', [String], $attributeCollection)
            #expose the name of our parameter
            $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add('UserName', $UserNameParam)
            return $paramDictionary
        }
        if ($MAC) {
            #add our paramater specifying the attribute collection
            $MACAddressParam = New-Object System.Management.Automation.RuntimeDefinedParameter('MACAddress', [String], $attributeCollection)
            #expose the name of our parameter
            $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add('MACAddress', $MACAddressParam)
            return $paramDictionary
        }
        if ($CountOSVersion) {
            # Generate and set the ValidateSet 
            $arrSet = "Win10 - 1507", "Win10 - 1511", "Win10 - 1607", "Win10 - 1703", "Win10 - 1709", "Win10 - 1803", "Win10 - 1809", "Win10 - 1903", "Win10 - 1909", "Win10 - 20H1", "Win10 - 20H2", "Win10 - 21H1", "Win10 - 21H2", "Win11 - 21H2"
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
            # Add the ValidateSet to the attributes collection
            $AttributeCollection.Add($ValidateSetAttribute)
            #add our paramater specifying the attribute collection
            $OSParam = New-Object System.Management.Automation.RuntimeDefinedParameter('OS', [String], $attributeCollection)
            #expose the name of our parameter
            $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add('OS', $OSParam)
            return $paramDictionary
        }
    }
    Process {
        Import-MEMModule A00
        If ($Computer) { Get-CMDevice | Where-Object { $_.Name -eq $PSBoundParameters.ComputerName } | Select-Object Name, UserName, PrimaryUser, MACAddress, ADSiteName, BoundaryGroups, DeviceOSBuild, ClientVersion }
        elseif ($User) { Get-CMDevice | Where-Object { $_.username -eq $PSBoundParameters.UserName } | Select-Object Name, UserName, PrimaryUser, MACAddress, ADSiteName, BoundaryGroups, DeviceOSBuild, ClientVersion }
        elseif ($Mac) { 
            $MacAddress = $PSBoundParameters.MACAddress
            $SupportedPattern = "(([0-9A-Fa-f]{2}[-. :]){5}[0-9A-Fa-f]{2})|(([0-9A-Fa-f]{4}[-: .]){2}[0-9A-Fa-f]{4})|[0-9A-Fa-f]{12}"
            $PaterntoConvert = "(([0-9A-Fa-f]{2}[-. ]){5}[0-9A-Fa-f]{2})|(([0-9A-Fa-f]{4}[-: .]){2}[0-9A-Fa-f]{4})|[0-9A-Fa-f]{12}"
            If ($MacAddress -match $SupportedPattern) {
                If ($MacAddress -match $PaterntoConvert) {
                    Write-Host "$MacAddress needs to be converted"
                    If ($MacAddress -match "(([0-9A-Fa-f]{2}[-]){5}[0-9A-Fa-f]{2})") {
                        $MacAddress = $MacAddress.Replace("-", ":")
                    }
                    elseif ($MacAddress -match "(([0-9A-Fa-f]{2}[ ]){5}[0-9A-Fa-f]{2})") {
                        $MacAddress = $MacAddress.Replace(" ", ":")
                    }
                    elseif ($MacAddress -match "(([0-9A-Fa-f]{2}[.]){5}[0-9A-Fa-f]{2})") {
                        $MacAddress = $MacAddress.Replace(".", ":")
                    }
                    elseif ($MacAddress -match "(([0-9A-Fa-f]{4}[-]){2}[0-9A-Fa-f]{4})") {
                        $MacAddress = $MacAddress.Replace("-", "")
                        $MacAddress = $MacAddress -split '(..)' -ne '' -join ':'
                    }
                    elseif ($MacAddress -match "(([0-9A-Fa-f]{4}[:]){2}[0-9A-Fa-f]{4})") {
                        $MacAddress = $MacAddress.Replace(":", "")
                        $MacAddress = $MacAddress -split '(..)' -ne '' -join ':'
                    }
                    elseif ($MacAddress -match "(([0-9A-Fa-f]{4}[ ]){2}[0-9A-Fa-f]{4})") {
                        $MacAddress = $MacAddress.Replace(" ", "")
                        $MacAddress = $MacAddress -split '(..)' -ne '' -join ':'
                    }
                    elseif ($MacAddress -match "(([0-9A-Fa-f]{4}[.]){2}[0-9A-Fa-f]{4})") {
                        $MacAddress = $MacAddress.Replace(".", "")
                        $MacAddress = $MacAddress -split '(..)' -ne '' -join ':'
                    }
                    elseif ($MacAddress -match "[0-9A-Fa-f]{12}") {
                        $MacAddress = $MacAddress -split '(..)' -ne '' -join ':'
                    }
                }
                elseif ($MacAddress -notmatch $SupportedPattern) {
                    Write-Host "$MacAddress is not a valid MAC Address"
                }   
            }
            Get-CMDevice | Where-Object { $_.MACAddress -match $MacAddress } | Select-Object Name, UserName, PrimaryUser, MACAddress, ADSiteName, BoundaryGroups, DeviceOSBuild, ClientVersion 
        }
        elseif ($CountOSVersion) {
            Write-Host "Total devices running $($PSBoundParameters.OS):"
            Switch ($PSBoundParameters.OS) {
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
    }
}