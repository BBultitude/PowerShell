Function Get-SAMSUNGLatestOSandPatch {
    <#
    .SYNOPSIS
       Get Samsung OS and Patch details.
    .DESCRIPTION
       Get Samsung mobile Models latest OS and Security Patch details by vendor.
    .PARAMETER GridView
       Defines if outputs to a Grid.
    .PARAMETER Models
       Defines what models you want to look up
    .INPUTS
       N/A.
    .OUTPUTS
       N/A.
    .NOTES
       Version:        1.0
       Author:         Bryan Bultitude
       Creation Date:  09/03/2022
       Purpose/Change: 09/03/2022 - Bryan Bultitude - Initial script development
    .EXAMPLE
       PS> Get-SAMSUNGLatestOSandPatch
    .EXAMPLE
       PS> Get-SAMSUNGLatestOSandPatch -GridView
    .EXAMPLE
       PS> Get-SAMSUNGLatestOSandPatch -Models "SM-A426B","SM-A520F","SM-A525F"
    #>
    param (
        [Parameter(Mandatory=$False)]
        [Switch]
        $GridView = $false,
        [Parameter(Mandatory=$False)]
        $Models = ("SM-A305YN","SM-A315G","SM-A426B","SM-A520F","SM-A525F","SM-A528B","SM-G398FN","SM-G570Y","SM-G781B","SM-G920I","SM-G930F","SM-G9350","SM-G950F","SM-G955F","SM-G960F","SM-G965F","SM-G970F","SM-G973F","SM-G975F","SM-G977B","SM-G980F","SM-G981B","SM-G986B","SM-G988B","SM-G991B","SM-G996B","SM-G998B","SM-J530Y","SM-N960F","SM-N9750","SM-N975F","SM-N976B","SM-N981B","SM-N986B","SM-P610","SM-T365Y","SM-T395","SM-T505","SM-T545")
    )
    $baseURI = "https://www.sammobile.com/samsung/security"
    $Vendors = "TEL", "OPS", "VAU", "XSA"
    $Results = @()
    $x = $Models.Count * 4
    $i = 0
    Foreach ($Model in $models) {
        #Creates Hashtable for each model
        $ModelResult = [PSCustomObject]@{Model = $Model; 'Telstra OS' = "" ; 'Telstra Patch' = "" ; 'Optus OS' = "" ; 'Optus Patch' = "" ; 'Vodafone OS' = "" ; 'Vodafone Patch' = "" ; 'Australia OS' = "" ; 'Australia Patch' = "" }
        Foreach ($Vendor in $Vendors) {
            $i += 0.25
            Write-Progress -activity "Grabbing Samsung Mobile OS and Patch Data" -status "Working on $Model $Vendor. Overall Progress: $([Math]::Round(($i / $x) * 100,2))%" -PercentComplete (($i / $x) * 100)
            #initial webscrape
            $website = Invoke-WebRequest -Uri "$baseURI/$Model/$Vendor"
            $table = $website.AllElements | Where-Object { $_.tagname -eq "table" }
            #grab url with information on model security patch level
            $table.innerhtml -split "(https:\/\/([a-zA-Z]+(\.[a-zA-Z]+)+)\/[a-zA-Z]+\/.*\/[a-zA-Z]+\/.*[a-zA-Z]+\/.+\b\/)" | ForEach-Object { if ($_ -match "(https:\/\/([a-zA-Z]+(\.[a-zA-Z]+)+)\/[a-zA-Z]+\/.*\/[a-zA-Z]+\/.*[a-zA-Z]+\/.+\b\/)") { $URL = $_ } }
            $URLINFO = Invoke-WebRequest -Uri "$URL"
            $SecurityINfo = $URLINFO.AllElements | Where-Object { $_.tagname -eq "table" }
            $securityinfo = $SecurityINfo.innerText.Split()
            $Patch = ""
            Foreach ($SI in $SecurityINfo) {
                if ($SI -match "([0-9]{4}-[0-9]{2}-[0-9]{2})") { $Patch = $si }
            }
            $i += 0.25
            Write-Progress -activity "Grabbing Samsung Mobile OS and Patch Data" -status "Working on $Model $Vendor. Overall Progress: $([Math]::Round(($i / $x) * 100,2))%" -PercentComplete (($i / $x) * 100)
            #finsh grabing OS version
            $data = $table | Select-Object OuterText -Last 1
            $data = $data.outerText.Split()
            $OS = ""
            Foreach ($item in $data) {
                if ($item -match "([0-9]{4}-[0-9]{2}-[0-9]{2})") {
                    $item = [regex]::split($item, "[0-9]{4}-[0-9]{2}-[0-9]{2}")
                    $OS = $item[1]
                }
            }
            #add vendor information into hastable
            Switch ($Vendor) {
                TEL {
                    $ModelResult.'Telstra OS' = $OS
                    $ModelResult.'Telstra Patch' = $Patch
                }
                OPS {
                    $ModelResult.'Optus OS' = $OS
                    $ModelResult.'Optus Patch' = $Patch
                }
                VAU {
                    $ModelResult.'Vodafone OS' = $OS
                    $ModelResult.'Vodafone Patch' = $Patch
                }
                XSA {
                    $ModelResult.'Australia OS' = $OS
                    $ModelResult.'Australia Patch' = $Patch
                }
            }
            $i += 0.5
            Write-Progress -activity "Grabbing Samsung Mobile OS and Patch Data" -status "Working on $Model $Vendor. Overall Progress: $([Math]::Round(($i / $x) * 100,2))%" -PercentComplete (($i / $x) * 100)
        }
        $Results += $ModelResult
    }
    Switch ($GridView) {
        $true { $Results | Out-GridView -Title "Samsung Mobile OS and Patch Data" }
        $false { $Results | Format-Table -AutoSize }
    }   
}