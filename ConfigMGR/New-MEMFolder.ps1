Function New-MEMFolder {
    <#
    .SYNOPSIS
        Creates folder
    .DESCRIPTION
        New-MEMFolder creates a new Configuration Manager folder if it doesnt already exist
    .PARAMETER FolderName
        Specifies the Folder Name to be created
    .PARAMETER Type
        Specifies the Area in Configuration Manager the folder is to be created in
    .PARAMETER SiteCode
        Specifies the Site Code for the Configuration Manager environment
    .INPUTS
        None
    .OUTPUTS
        None
    .NOTES
        Version:        1.2
        Author:         Bryan Bultitude
        Creation Date:  25/06/2021
        Purpose/Change: 25/06/2021 - Bryan Bultitude - Initial script development
                        21/09/2021 - Bryan Bultitude - Updated Function name to be different from Configuration Module Functions
                        09/12/2021 - Bryan Bultitude - Moved Comment Based Help to top of function
    .EXAMPLE
        PS> New-MEMFolder -SiteCode "A00" -FolderName "Test" -Area "Application"
    #>
    param ([Parameter(Mandatory = $true)]$SiteCode,
        [Parameter(Mandatory = $true)]$FolderName,
        [Parameter(Mandatory = $true)]
        [ValidateSet("Application", "BootImage", "ConfigurationBaseline", "ConfigurationItem", "DeviceCollection", "Driver", "DriverPackage", "OperatingSystemImage", "OperatingSystemInstaller", "Package", "Query", "SoftwareMetering", "SoftwareUpdate", "TaskSequence", "UserCollection", "UserStateMigration", "VirtualHardDisk", "SmsProvider")]$Area)
    if (-not (Get-ChildItem "$SiteCode`:\$Area\$FolderName")) {
        Write-Host "$(Get-Date):   Folder does not exist, creating it." -ForegroundColor Green
        New-Item -Path "$SiteCode`:\$Area" -Name $FolderName -ItemType "directory"
        Write-Host "$(Get-Date):   Folder created. If folder isn't visible please close your ConfigMGR Console and reopoen it" -ForegroundColor DarkYellow
    }
    Else {
        Write-Host "$(Get-Date):   Folder exist, moving on." -ForegroundColor DarkYellow
    }
}


