function Get-CMWSUSandADRStatus {
   Import-CMModule A00
   Get-CMSoftwareUpdateSyncStatus | Format-Table @{L = 'WSUS Server'; E = { $_.WSUSServerName } }, @{L = 'Site Code'; E = { $_.SiteCode } }, @{L = 'Version'; E = { $_.SyncCatalogVersion } }, @{L = 'Sync Time'; E = { $_.LastSyncStateTime } }, @{L = 'Last Error'; E = { $_.LastSyncErrorCode } } -AutoSize
   Get-CMSoftwareUpdateAutoDeploymentRule -Fast | Format-Table Name, @{L = 'Last Run Time'; E = { $_.LastRunTime } }, @{L = 'Last Error Code'; E = { $_.LastErrorCode } }, @{L = 'Last Error Time'; E = { $_.LastErrorTime } }  -AutoSize
   Set-Location $env:HOMEDRIVE
   <#
.SYNOPSIS
   Get WSUS and ADR Info.
.DESCRIPTION
   Quick overview of WSUS Sync Status and ADR Run status
.INPUTS
   N/A
.OUTPUTS
   N/A
.NOTES
   Version:        1.0
   Author:         Bryan Bultitude
   Creation Date:  21/09/2021
   Purpose/Change: Initial script development
.EXAMPLE
   PS> Get-CMWSUSandADRStatus
#>
}