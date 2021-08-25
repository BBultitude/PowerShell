<#
.SYNOPSIS
    Cleans up deployments
.DESCRIPTION
    Remove-CMDeploymentsforCollectionName removes all Configuration Manager deployments to the Collection Name specified
.PARAMETER CollectionName
    Specifies the Collection Name to be run against
.INPUTS
    None
.OUTPUTS
    None
.NOTES
    Version:        1.0
    Author:         Bryan Bultitude
    Creation Date:  24/08/2021
    Purpose/Change: Initial script development
.EXAMPLE
    PS> Remove-CMDeploymentsforCollectionName -CollectionName "Dodgy Collection Name"
#>
function Remove-CMDeploymentsforCollectionName ($CollectionName) {
    Get-CMDeployment -CollectionName $CollectionName | ForEach-Object { Write-Host $_.ApplicationName
        Remove-CMDeployment -ApplicationName $_.ApplicationName  -DeploymentId $_.Deploymentid -Force }
}