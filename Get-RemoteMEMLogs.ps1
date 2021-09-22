Function Get-MEMRemoteLogs {
  Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'ConfigMGR')][Switch]$ConfigMGR = $false,
    [Parameter(Mandatory = $true, ParameterSetName = 'RemotePC')][Switch]$RemotePC = $false,
    [Parameter(Mandatory = $true, ParameterSetName = 'RemotePC')]$ComputerName
  )
  if ($ConfigMGR -eq $true) {
    New-PSDrive -Name ConfigMGRRemoteLogs -PSProvider FileSystem -Root "\\bnesccm01\d$\Program Files\Microsoft Configuration Manager\Logs"
  }
  elseif ($RemotePC -eq $true) {
    New-PSDrive -Name ConfigMGRRemoteLogs -PSProvider FileSystem -Root "\\$ComputerName\C$\Windows\CCM\Logs"
  }
  $Drive = 'ConfigMGRRemoteLogs:'
  $CMLogfiles = Get-ChildItem -Path $Drive -Include *.log, *.lo_ -Recurse
  $CMLOGFILENAMES = $CMLogfiles.Name
  $Counter = 0
  $CMARRAYLOGS = @()
  foreach ($log in $CMLOGFILENAMES) {
    $Counter ++
    $CMARRAYLOGS += "$counter $Log"
  }
  $chunkSize = ($CMARRAYLOGS.Count / 2)
  $outArray1 = @()
  $outArray2 = @()
  $parts = [math]::Ceiling($CMARRAYLOGS.Length / $chunkSize)
  $start1 = 0 * [Math]::ceiling($chunkSize)
  $start2 = 1 * [Math]::ceiling($chunkSize)
  $Chunk = 0
  do {
    $outArray1 += $CMARRAYLOGS[$start1]
    $outArray2 += $CMARRAYLOGS[$start2]
    $start1++
    $start2++
    $chunk++
  }
  until ($Chunk -eq [Math]::ceiling($chunkSize))
  $output = @()
  $x = 0
  Do {
    $Row = New-Object -TypeName PSObject
    $Row | Add-Member -MemberType NoteProperty -Name Column1 -Value $outArray1[$x]
    $Row | Add-Member -MemberType NoteProperty -Name Column2 -Value $outArray2[$x]
    $output += $Row
    $x++
  } until ($x -eq [Math]::ceiling($chunkSize))
  Write-Host 
  Write-Host
  Write-Host "Log Files:"
  $output | Format-Table -AutoSize -HideTableHeaders
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
 PS> Get-MEMRemoteLogs -ConfigMGR
.EXAMPLE
 PS> Get-MEMRemoteLogs -RemotePC -ComputerName
#>
}