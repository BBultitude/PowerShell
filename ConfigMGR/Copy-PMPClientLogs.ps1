Function Copy-PMPClientLogs {
    <#
    .SYNOPSIS
       Collect PMP Logs
    .DESCRIPTION
       Collect client logs for PatchMyPC support tickets
    .PARAMETER Computers
       Array of computers to get logs from
    .PARAMETER Destination
       Where the logs will be copied to
    .INPUTS
       N/A
    .OUTPUTS
       N/A
    .NOTES
       Version:        1.0
       Author:         Bryan Bultitude
       Creation Date:  17/06/2022
       Purpose/Change: 17/06/2022 - Bryan Bultitude - Initial script development
    .EXAMPLE
       PS> Copy-PMPClientLogs -Computers "BBWIN10-01" -Destination "C:\Temp\PMPLogs\"
    .EXAMPLE
       PS> Copy-PMPClientLogs  -Computers "BBWIN10-01","BBWIN10-02","BBWIN10-03" -Destination "C:\Temp\PMPLogs"
    #>
    param (
        [Parameter(Mandatory = $true)] $Computers,
        [Parameter(Mandatory = $true)] $Destination
    )
    $FinalDestination = $Destination.TrimEnd("\")
    foreach ($Computer in $Computers) {
        if (test-connection $computer -Count 1 -Quiet) {
            $Files = "\\$Computer\c$\Windows\CCM\Logs\AppDiscovery*.log", "\\$Computer\c$\Windows\CCM\Logs\AppEnforce*.log", "\\$Computer\c$\Windows\CCM\Logs\AppIntentEval*.log", "\\$Computer\c$\Windows\CCM\Logs\CAS*.log", "\\$Computer\c$\Windows\CCM\Logs\CIAgent.*log", "\\$Computer\c$\Windows\CCM\Logs\DataTransferService*.log", "\\$Computer\c$\Windows\CCM\Logs\PatchMyPC-ScriptRunner.log", "\\$Computer\c$\Windows\CCM\Logs\PatchMyPC-SoftwareDetectionScript.log", "\\$Computer\c$\Windows\CCM\Logs\StateMessage.log", "\\$Computer\c$\ProgramData\PatchMyPC\PatchMyPC-UserNotification.log", "\\$Computer\c$\ProgramData\PatchMyPC\UISettings\UINotificationSettings.xml"
            $Folder = "$FinalDestination\$Computer"
            if (!(Test-Path $folder)) {
                New-Item -Path $FinalDestination -Name $Computer -ItemType Directory
            }
            foreach ($File in $Files) {
                Copy-Item -Path $File  -Destination $Destination\$Computer -Force -ErrorAction SilentlyContinue
            }   
        }
        else { Write-Warning "$Computer is off" }   
    }
}