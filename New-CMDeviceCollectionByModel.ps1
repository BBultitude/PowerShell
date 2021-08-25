<#
.SYNOPSIS
    Creates collections based on models
.DESCRIPTION
    New-CMDeviceCollectionByModel creates new collections based on inventoried devices models
.PARAMETER SiteCode
    Specifies the Site Code for the Configuration Manager environment
.PARAMETER FolderName
    Specifies the Folder for the Collection to be moved to onece it has been created
.PARAMETER LimitingCollection
    Specifies the Collection ID to limit the new Collection by
.INPUTS
    None
.OUTPUTS
    None
.NOTES
    Version:        1.0
    Author:         Bryan Bultitude
    Creation Date:  25/06/2021
    Purpose/Change: Initial script development
.EXAMPLE
    PS> New-CMDeviceCollectionByModel -SiteCode "A00" -FolderName "Test" -LimitingCollection "SMS00001"
#>
function New-CMDeviceCollectionByModel {
    param ([Parameter(Mandatory = $true)]$Script:SiteCode,
        [Parameter(Mandatory = $true)]$Script:FolderName,
        [Parameter(Mandatory = $true)]$script:LimitingCollection)
    Import-CMModule -SiteCode $script:SiteCode
    New-CMDeviceCollectionByModel -Type DeviceCollection -FolderName $script:FolderName
    $WQL = @"
select distinct SMS_G_System_COMPUTER_SYSTEM.Model from  SMS_G_System_COMPUTER_SYSTEM where SMS_G_System_COMPUTER_SYSTEM.Model not like "VMware%" and SMS_G_System_COMPUTER_SYSTEM.Model != "Virtual Machine"
"@

    $Models = Invoke-CMWmiQuery -Query $WQL | Select-Object Model | Sort-Object Model

    foreach ($Model in $Models) {
        $Model = ($Model.Model)
        if (-not (Get-CMDeviceCollection -Name $Model)) {
            $Response = Read-Host "
$(Get-Date):   Are you sure you want to create new collection for: `"$($Model)`" ? (Y/N)"
            Write-Host ""
            switch ($Response) {
                Y {
                    Write-Host "$(Get-Date):   Creating Device Collection `"$($Model)`"" -ForegroundColor Green
                    $Schedule = New-CMSchedule -RecurInterval Days -RecurCount 7
                    $Coll = New-CMDeviceCollection -LimitingCollectionId $LimitingCollection -Name $Model -RefreshSchedule $Schedule -Comment "All $Model workstations"
                    $QueryExpression = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model = `"$Model`""
                    Add-CMDeviceCollectionQueryMembershipRule -CollectionId $Coll.CollectionID -RuleName "All $($Model) workstations" -QueryExpression $QueryExpression
                    Get-CMCollection -Name $Model | Move-CMObject -FolderPath "$SiteCode`:\DeviceCollection\$FolderName"
                }
                N { Write-Host "$(Get-Date):   Device Collection `"$($Model)`" not being created as requested, skipping it." -ForegroundColor DarkYellow }
                Default { Write-Host "$(Get-Date):   Device Collection `"$($Model)`" not being created due to no valid response, skipping it." -ForegroundColor Red }
            }
        }
        else {
            Write-Host "$(Get-Date):   Device Collection `"$($Model)`" already exists, skipping it." -ForegroundColor DarkYellow
        }
    }
}