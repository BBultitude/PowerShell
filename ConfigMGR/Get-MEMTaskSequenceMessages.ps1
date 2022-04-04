function Get-MEMTaskSequenceMessages {
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
       Version:        1.1
       Author:         Bryan Bultitude
       Creation Date:  21/09/2021
       Purpose/Change: 21/09/2021 - Bryan Bultitude - Initial script development
                       09/12/2021 - Bryan Bultitude - Moved Comment Based Help to top of function
    .EXAMPLE
       PS> Get-MEMTaskSequenceMessages -Type "All"
    .EXAMPLE
       PS> Get-MEMTaskSequenceMessages -Type "Driver Update"
    .EXAMPLE
       PS> Get-MEMTaskSequenceMessages -Type "Operating System Deployment"
    .EXAMPLE
       PS> Get-MEMTaskSequenceMessages -Type "Error Logs Directory
   #>
   param (
      [Parameter(Mandatory = $true)]
      [ValidateSet("All", "Driver Update", "Operating System Deployment", "Error Logs Directory")]$Type
   )
   Import-MEMModule A00
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
         Invoke-Item "\\SERVER\SHARE\SCCM_OSD_Logs" 
      }
   }
}