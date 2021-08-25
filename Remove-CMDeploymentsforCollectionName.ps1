function Remove-CMDeploymentsforCollectionName ($CollectionName) {
    Get-CMDeployment -CollectionName $CollectionName | ForEach-Object { Write-Host $_.ApplicationName
        Remove-CMDeployment -ApplicationName $_.ApplicationName  -DeploymentId $_.Deploymentid -Force }
}