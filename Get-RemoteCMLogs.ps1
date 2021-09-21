Function Get-RemoteCMLogs {
   Param(
      [Parameter(Mandatory = $true, ParameterSetName = 'ConfigMGR')][Switch]$ConfigMGR = $false,
      [Parameter(Mandatory = $true, ParameterSetName = 'RemotePC')][Switch]$RemotePC = $false,
      [Parameter(Mandatory = $true, ParameterSetName = 'RemotePC')]$ComputerName
   )
   if ($ConfigMGR -eq $true) {
      New-PSDrive -Name ConfigMGRRemoteLogs -PSProvider FileSystem -Root "\\SERVERNAME\d$\Program Files\Microsoft Configuration Manager\Logs"

   }
   elseif ($RemotePC -eq $true) {
      New-PSDrive -Name ConfigMGRRemoteLogs -PSProvider FileSystem -Root "\\$ComputerName\C$\Windows\CCM\Logs"
   }


   $Drive = 'ConfigMGRRemoteLogs:'
   $CMLogfiles = Get-ChildItem -Path $Drive -Include *.log, *.lo_ -Recurse
   $CMLOGFILENAMES = $CMLogfiles.Name
   $CMARRAYLOGS = @()
   $Counter = 0
    
   foreach ($log in $CMLOGFILENAMES) {
      $Counter ++
      $CMARRAYLOGS += "$counter $Log"
   }
   Write-Host "Log Files:"
   Write-Host
   $CMARRAYLOGS
   Write-Host 
   Write-Host
   Write-Host
   [Int]$userinput = Read-Host -Prompt "Enter Log Number"
   if ($userinput -eq "0") { }
   Else {
      $logtoread = [Int]$userinput - 1
      $OldLogName = $CMARRAYLOGS[$logtoread]
      $seporator = " "
      $parts = $OldLogName.Split($seporator)
      $newlogname = $parts[1]
      $CURRENTDIR = Get-Location
      Set-Location $Drive
      Start-process Cmtrace.exe $newlogname
      Set-Location $CURRENTDIR
      Remove-PSDrive ConfigMGRRemoteLogs -ErrorAction SilentlyContinue
   }
   <#
.SYNOPSIS
   Get remote logs for Configuration Manager.
.DESCRIPTION
   Get remote logs of Configruation Manager Primary Server or of remote systems' Configuration Manager Agent.
.PARAMETER ConfigMGR
   Switches to get logs for Configuration Manager Primary Server. Not to be used with any other Parameters.
.PARAMETER RemotePC
   Switches to get logs for Configuration Manager Agent for remote systems. Not to be used with -ConfigMGR
.PARAMETER ComputerName
   Mandatory requirement when -RemotePC used. Parameter used to specify which computer to get logs from
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
   PS> Get-RemoteCMLogs -ConfigMGR
.EXAMPLE
   PS> Get-RemoteCMLogs -RemotePC -ComputerName
#>
}