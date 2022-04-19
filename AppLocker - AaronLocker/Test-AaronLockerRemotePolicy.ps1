function Test-AaronLockerRemotePolicy {
    <#
    .SYNOPSIS
       Checks AaronLocker Policy on remote system.
    .DESCRIPTION
       Checks AaronLocker Policy on remote system for specific file and user type.
    .PARAMETER UserType
       User type to be checked against.
    .PARAMETER File
       Full local file path to file that is to be tested.
    .PARAMETER Computer
       Remote system to be tested.
    .INPUTS
       N/A.
    .OUTPUTS
       N/A.
    .NOTES
       Version:        1.0
       Author:         Bryan Bultitude
       Creation Date:  10/01/2022
       Purpose/Change: 10/01/2022 - Bryan Bultitude - Initial script development
    .EXAMPLE
       PS> Test-AaronLockerRemotePolicy -UserType Administrators -File "C:\USERS\BOB\REPOS\RESTSHARP.DLL" -Computer Test
    #>
    param (
       [Parameter(Mandatory = $true)]
       [ValidateSet("Users", "Administrators")]
       $UserType,
       [Parameter(Mandatory = $true)]
       $File,
       [Parameter(Mandatory = $true)]
       $Computer
    )
    Invoke-Command -ComputerName $Computer -ArgumentList $File, $UserType -ScriptBlock {
       $File = $args[0]
       $UserType = $args[1]
       $SourceExists = Test-Path C:\Source
       If (!($SourceExists)) {
          New-Item -Path "C:\" -Name "Source" -ItemType Directory
       }
       $xml = "C:\Source\effective.xml"
       Get-AppLockerPolicy -Effective -Xml | Out-File $xml -Force
       Test-AppLockerPolicy -Path $File -XmlPolicy $xml -User $UserType
       Remove-Item $xml
    }
 }