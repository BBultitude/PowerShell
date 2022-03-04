function Get-MEMDistributionOverview {
   <#
   .SYNOPSIS
      Quick overview of currently distributing content.
   .DESCRIPTION
      Provides and overview of Success, Failure, Unknown and In progress status of sending content to distribution points.
   .PARAMETER GridView
      This parameter switches from output as a table in PowerShell to a GUI Grid View
   .INPUTS
      N/A
   .OUTPUTS
      N/A
   .NOTES
      Version:        1.1
      Author:         Bryan Bultitude
      Creation Date:  21/09/2021
      Purpose/Change: 21/09/2021 - Bryan Bultitude - Initial script development
                      09/12/2021 - Bryan Bultitude - Moved Comment Based Help to top of function
   .EXAMPLE
      PS> Get-MEMDistributionOverview
   .EXAMPLE
      PS> Get-MEMDistributionOverview -GridView
   #>
    Param(
    [Parameter(Mandatory = $false)][Switch]$GridView = $false
    )
    Import-MEMModule A00
    if ($GridView -eq $true) {
        Get-CMDistributionStatus | Where-Object { $_.NumberErrors -gt 0 -or $_.NumberInProgress -gt 0 -or $_.NumberUnknown -gt 0 } | Select-Object @{L = 'Content Name'; E = { $_.SoftwareName } }, @{L = 'Success'; E = { $_.NumberSuccess } }, @{L = 'In Progress'; E = { $_.NumberInProgress } }, @{L = 'Error'; E = { $_.NumberErrors } }, @{L = 'Unknown'; E = { $_.NumberUnknown } } | Out-GridView -Title "Content Distribution Status - Count of Distribution Points"
    }
    else {
        Get-CMDistributionStatus | Where-Object { $_.NumberErrors -gt 0 -or $_.NumberInProgress -gt 0 -or $_.NumberUnknown -gt 0 } | Select-Object @{L = 'Content Name'; E = { $_.SoftwareName } }, @{L = 'Success'; E = { $_.NumberSuccess } }, @{L = 'In Progress'; E = { $_.NumberInProgress } }, @{L = 'Error'; E = { $_.NumberErrors } }, @{L = 'Unknown'; E = { $_.NumberUnknown } } | Format-Table -AutoSize
    }
    Set-Location $env:HOMEDRIVE
    
}