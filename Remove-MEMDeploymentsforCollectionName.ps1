function Remove-MEMDeploymentsforCollectionName ($CollectionName) {
   <#
   .SYNOPSIS
      Removes all deployments for a collection
   .DESCRIPTION
      Removes all deployments for a specified collection name
   .PARAMETER CollectionName
      Name of the device or user collection that you want to remove all deployments from
   .INPUTS
      N/A
   .OUTPUTS
      N/A
   .NOTES
      Version:        1.2
      Author:         Bryan Bultitude
      Creation Date:  25/08/2021
      Purpose/Change: 25/08/2021 - Bryan Bultitude - Initial script development
                      21/09/2021 - Bryan Bultitude - Updated Function name to be different from Configuration Module Functions
                      09/12/2021 - Bryan Bultitude - Moved Comment Based Help to top of function
   .EXAMPLE
      PS> Remove-MEMDeploymentsforCollectionName -CollectionName "Dodgy Collection Name Goes Here"
   #>
   Import-MEMModule A00
   Get-CMDeployment -CollectionName $CollectionName | ForEach-Object { Write-Host $_.ApplicationName
      Remove-CMDeployment -ApplicationName $_.ApplicationName  -DeploymentId $_.Deploymentid -Force
   }
   Set-Location $env:HOMEDRIVE
}