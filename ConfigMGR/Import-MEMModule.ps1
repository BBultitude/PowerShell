Function Import-MEMModule {
   <#
   .SYNOPSIS
      Imports Configuration Manager Module
   .DESCRIPTION
      Imports Configuration Manager Module if Console is installed and automatically detects location of module
   .PARAMETER SiteCode
      Site Code of Configuration Manager site
   .INPUTS
      N/A
   .OUTPUTS
      N/A
   .NOTES
      Version:        1.2
      Author:         Bryan Bultitude
      Creation Date:  25/06/2021
      Purpose/Change: 25/06/2021 - Bryan Bultitude - Initial script development
                      21/09/2021 - Bryan Bultitude - Updated Function name to be different from Configuration Module Functions
                      09/12/2021 - Bryan Bultitude - Moved Comment Based Help to top of function
                      04/07/2022 - Bryan Bultitude - Added output to display module version
                      07/07/2022 - Bryan Bultitude - Changed from exit 1 to use Break so error is still visible
   .EXAMPLE
      Import-MEMModule A00
   .EXAMPLE
      Import-MEMModule -SiteCode A00
   #>
   param ([Parameter(Mandatory = $true)]$SiteCode)
   if (-not (Test-Path -Path "$SiteCode`:")) {
      $CCMModuleInfo = Import-PowerShellDataFile -Path (Join-Path (Split-Path $env:SMS_ADMIN_UI_PATH -parent) ConfigurationManager.psd1)
      Write-Host "$(Get-Date):   ConfigMgr module has not been imported yet, will import it now." -ForegroundColor Green
      Write-Host "$(Get-Date):   ConfigMgr module version is $($CCMModuleInfo.ModuleVersion)" -ForegroundColor Green
      Import-Module (Join-Path (Split-Path $env:SMS_ADMIN_UI_PATH -parent) ConfigurationManager.psd1) | Out-Null
      Set-Location "$($SiteCode):" | Out-Null
   }
   elseif (Test-Path -Path "$SiteCode`:") {
      $CCMModuleInfo = Import-PowerShellDataFile -Path (Join-Path (Split-Path $env:SMS_ADMIN_UI_PATH -parent) ConfigurationManager.psd1)
      Write-Host "$(Get-Date):   ConfigMgr module version is $($CCMModuleInfo.ModuleVersion)" -ForegroundColor Green
      Write-Host "$(Get-Date):   ConfigMgr module has already been imported" -ForegroundColor DarkYellow
      Set-Location "$($SiteCode):" | Out-Null
   }
   if (-not (Get-PSDrive -Name $SiteCode)) {
      Write-Error "There was a problem loading the Configuration Manager powershell module and accessing the site's PSDrive."
      Break
   }
}