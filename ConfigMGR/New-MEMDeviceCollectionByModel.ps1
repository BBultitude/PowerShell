function New-MEMDeviceCollectionByModel {
    <#
    .SYNOPSIS
        Creates collections based on models
    .DESCRIPTION
        New-MEMDeviceCollectionByModel creates new collections based on inventoried devices models
    .INPUTS
        None
    .OUTPUTS
        None
    .NOTES
        Version:        1.3
        Author:         Bryan Bultitude
        Creation Date:  25/06/2021
        Purpose/Change: 25/06/2021 - Bryan Bultitude - Initial script development
                        21/09/2021 - Bryan Bultitude - Updated Function name to be different from Configuration Module Functions
                        09/12/2021 - Bryan Bultitude - Moved Comment Based Help to top of function
                        17/03/2022 - Victor Rodriguez - Added HP Product ID to Comment, and changed the filtering (replace)
    .EXAMPLE
        PS> New-MEMDeviceCollectionByModel
    #>
    $script:FolderName = "By Model"
    $script:SiteCode = 'A00'
    $script:LimitingCollection = "A00000CD"
    Import-MEMModule -SiteCode $script:SiteCode
    New-MEMFolder -SiteCode $SiteCode -Area DeviceCollection -FolderName $script:FolderName
    $WQL =  @"
select distinct
    SMS_G_System_COMPUTER_SYSTEM.Model,
    SMS_G_System_BASEBOARD.Product 
from 
    SMS_R_System 
    inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId 
    inner join SMS_G_System_BASEBOARD on SMS_G_System_BASEBOARD.ResourceID = SMS_R_System.ResourceId 
where
    SMS_G_System_COMPUTER_SYSTEM.Model not like "VMware%" 
    and SMS_G_System_COMPUTER_SYSTEM.Model != "Virtual Machine"
"@
    $Models = Invoke-CMWmiQuery -Query $WQL 
    foreach ($Item in $Models) {
       
        $Model = ($Item.SMS_G_System_COMPUTER_SYSTEM.Model) -replace "Tablet|Notebook PC|WKS TWR|SFF|TWR|Desktop Mini|DM|MT|Mobile Workstation|2KQ75PA#ABG|Workstation|PC",""
       
        if (-not (Get-CMDeviceCollection -Name $Model)) {
            $Response = Read-Host "
            $(Get-Date):   Are you sure you want to create new collection for: `"$($Model)`" ? (Y/N)"
            Write-Host ""
            switch ($Response) {
                Y {
                    Write-Host "$(Get-Date):   Creating Device Collection `"$($Model)`"" -ForegroundColor Green
                    $Schedule = New-CMSchedule -RecurInterval Days -RecurCount 7
                    $Coll = New-CMDeviceCollection -LimitingCollectionId $LimitingCollection -Name $Model -RefreshSchedule $Schedule -Comment "All $Model workstations - ($($Item.SMS_G_System_BASEBOARD.Product))"
                    $QueryExpression = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like `"%$Model%`""
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
    Set-Location $env:HOMEDRIVE\$env:HOMEPATH
}
