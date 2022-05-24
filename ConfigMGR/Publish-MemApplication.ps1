function Publish-MEMApplication {
    <#
    .SYNOPSIS
       Publish Applications to any Collection in Configuration Manager
    .DESCRIPTION
       Publish Applications to any Collection in Configuration Manager by using a fuzzy search for either Application Name or Publisher
    .PARAMETER ApplicationSearch
       Use to find applications named similar
    .PARAMETER PublisherSearch
       Use to find applications by publisher named similar
    .PARAMETER Purpose
       Type of deployment Forced (Required) or Available
    .INPUTS
       N/A
    .OUTPUTS
       N/A
    .NOTES
       Version:        1.0
       Author:         Bryan Bultitude
       Creation Date:  25/05/2022
       Purpose/Change: 25/05/2022 - Bryan Bultitude - Initial script development
    .EXAMPLE
       PS> Publish-MemApplication -ApplicationSearch CostX  -Purpose Available
    .EXAMPLE
       PS> Publish-MemApplication -PublisherSearch ET  -Purpose Required   
    #>
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Application')]
        $ApplicationSearch = "",
        [Parameter(Mandatory = $true, ParameterSetName = 'Publisher')]
        $PublisherSearch = "",
        [Parameter(Mandatory = $true, ParameterSetName = 'Application')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Publisher')]
        [ValidateSet("Available", "Required")]$Purpose
    )
    Import-MEMModule A00
    $DeadlineDateTime = (get-date -Hour 22 -Minute 00 -Second 00)
    $AvailableDateTime = $DeadlineDateTime.AddDays(-1)
    Write-Host "Importing all Device and User Collections" -ForegroundColor Cyan
    $Collections = @()
    $Collections += Get-CMDeviceCollection | Select-Object Name, @{Name = "Collection ID"; Expression = { $_.CollectionID } }, @{Name = "Collection Type"; Expression = { "Device" } }
    $Collections += Get-CMUserCollection | Select-Object Name, @{Name = "Collection ID"; Expression = { $_.CollectionID } }, @{Name = "Collection Type"; Expression = { "User" } }
    try {
        Import-MEMModule A00
        $DeadlineDateTime = (get-date -Hour 22 -Minute 00 -Second 00)
        $AvailableDateTime = $DeadlineDateTime.AddDays(-1)
        $Application = ""
        $Selection = ""
        if ($ApplicationSearch -ne "" -and $PublisherSearch -eq "") {
            Write-Host "Getting list of Applications named like: `"$ApplicationSearch`"" -ForegroundColor DarkGray
            $Application = Get-CMApplication -Fast | Where-Object { $_.LocalizedDisplayName -match $ApplicationSearch } | Select-Object @{Name = "Name"; Expression = { $_.LocalizedDisplayName } },SoftwareVersion,Manufacturer | Sort-Object Manufacturer,LocalizedDisplayName,SoftwareVersion | Out-GridView -Title "Which Application is being deployed?" -PassThru
        }
        elseif ($PublisherSearch -ne "" -and $ApplicationSearch -eq "") {
            Write-Host "Getting list of Applications from Publishers named like: `"$PublisherSearch`"" -ForegroundColor DarkGray
            $Application = Get-CMApplication -Fast | Where-Object { $_.Manufacturer -match $PublisherSearch } | Select-Object @{Name = "Name"; Expression = { $_.LocalizedDisplayName } },SoftwareVersion,Manufacturer | Sort-Object Manufacturer,LocalizedDisplayName,SoftwareVersion | Out-GridView -Title "Which Application is being deployed?" -PassThru
        }
        else {
            Write-Host "Incorrect Action Selected" -ForegroundColor Red
        }
        if ($Application -ne "") {
            Foreach ($App in $Application) {
                $ApplicationName = $App.Name
                Write-Host "Processing $($App.Name)"
                $Selection = $Collections | Sort-Object Name | Out-GridView -Title "Deploy $($App.Name) to which Collections?" -PassThru        
                if ($Selection -ne "") {
                    Foreach ($Coll in $Selection) {
                        if ($Coll.Name -ne "Applications for Workstations") {
                            Write-Host "Deploying to $($Coll.Name)" -ForegroundColor DarkGray
                            $Deployed = New-CMApplicationDeployment -CollectionId $Coll."Collection ID" -DeployAction Install -DeployPurpose $Purpose -Name $ApplicationName -UpdateSupersedence $True -AvailableDateTime $AvailableDateTime -DeadlineDateTime $DeadlineDateTime -TimeBaseOn LocalTime
                            Write-Host "Deployed $($Deployed.LocalizedDisplayName) to $($Coll.Name)" -ForegroundColor Green
                        }
                        elseif ($Coll.Name -eq "Applications for Workstations") {
                            Write-Host "Deploying to $($Coll.Name) with Approval Required" -ForegroundColor DarkGray
                            $Deployed = New-CMApplicationDeployment -CollectionId $Coll."Collection ID" -DeployAction Install -DeployPurpose Available -Name $ApplicationName -UpdateSupersedence $True -AvailableDateTime $AvailableDateTime -DeadlineDateTime $DeadlineDateTime -TimeBaseOn LocalTime -ApprovalRequired $true
                            Write-Host "Deployed $($Deployed.LocalizedDisplayName) to $($Coll.Name) with Approval Required" -ForegroundColor Green
                        }
                        $Selection = ""
                    }
                }
                Else { Throw "Nothing collections selected" }
            }
        }
        Else { Throw "No applications selected" }
    }
    catch {
        $Error[0].TargetObject
    }
}