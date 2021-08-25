Function Import-CMModule {
    param ([Parameter(Mandatory = $true)]$SiteCode)
    if (-not (Test-Path -Path "$SiteCode`:")) {
        Write-Host "$(Get-Date):   ConfigMgr module has not been imported yet, will import it now." -ForegroundColor Green
        Import-Module (Join-Path (Split-Path $env:SMS_ADMIN_UI_PATH -parent) ConfigurationManager.psd1) | Out-Null
        Set-Location "$($SiteCode):" | Out-Null
    }
    elseif (Test-Path -Path "$SiteCode`:") {
        Write-Host "$(Get-Date):   ConfigMgr module has already been imported" -ForegroundColor DarkYellow
        Set-Location "$($SiteCode):" | Out-Null
    }
    if (-not (Get-PSDrive -Name $SiteCode)) {
        Write-Error "There was a problem loading the Configuration Manager powershell module and accessing the site's PSDrive."
        exit 1
    }
}