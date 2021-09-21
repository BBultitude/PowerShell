function Get-CMTaskSequenceMessages {
   param (
      [Parameter(Mandatory = $true)]
      [ValidateSet("All", "Driver Update", "Operating System Deployment", "Error Logs Directory")]$Type
   )
   Import-CMModule A00
   switch ($Type) {
      "All" {
         Get-CMStatusMessageQuery -Id A00001B2 -ShowMessage
         Set-Location $env:HOMEDRIVE 
      }
      "Driver Update" {
         Get-CMStatusMessageQuery -Id A00001B3 -ShowMessage
         Set-Location $env:HOMEDRIVE 
      }
      "Operating System Deployment" {
         Get-CMStatusMessageQuery -Id A00001B4 -ShowMessage
         Set-Location $env:HOMEDRIVE
      }
      "Error Logs Directory" {
         Set-Location $env:HOMEDRIVE
         Invoke-Item "\\CUSTOMSHAREPATH\" 
      }
   }
   <#
    .SYNOPSIS
       Get task sequence information.
    .DESCRIPTION
       Get information for OSD, Driver Update, All or Error Messages for Task Sequences.
    .PARAMETER Type
       Switch between the different Status Message Queries or Task Sequence Error Logs Directory.
    .INPUTS
       N/A
    .OUTPUTS
       N/A
    .NOTES
       Version:        1.0
       Author:         Bryan Bultitude
       Creation Date:  xx/xx/20xx
       Purpose/Change: Initial script development
    .EXAMPLE
       PS> Get-CMTaskSequenceMessages -Type "All"
    .EXAMPLE
       PS> Get-CMTaskSequenceMessages -Type "Driver Update"
    .EXAMPLE
       PS> Get-CMTaskSequenceMessages -Type "Operating System Deployment"
    .EXAMPLE
       PS> Get-CMTaskSequenceMessages -Type "Error Logs Directory
    #>
}