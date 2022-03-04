function New-MEMApplicationBasedOnJSONFile {
   <#
.SYNOPSIS
   Creates application in Configuration Manager.
.DESCRIPTION
   Quicker way of creating applications in Configuration Manager but still requires end user to modify sections (NOT 100% AUTOMATED). This will open Notepad++ up for a JSON file to be updated and the Application will be created, distributed and deployed based on information entered
.INPUTS
   N/A.
.OUTPUTS
   N/A.
.NOTES
   Version:        1.1
   Author:         Bryan Bultitude
   Creation Date:  17/09/2021
   Purpose/Change: 17/09/2021 - Bryan Bultitude - Initial script development
                   09/12/2021 - Bryan Bultitude - Moved Comment Based Help to top of function
.EXAMPLE
   PS> New-MEMApplicationBasedOnJSONFile
#>
   Import-MEMModule A00
   $Today = Get-Date -Format d/MM/yyyy

   Set-Location $env:HOMEDRIVE
   $JSONContent = @"
{
	"Application": {
		"Name": "",
		"Admin Comment": "",
		"Publisher": "",
		"Version": ""		
	},
	"Software Center": {
        "Name":"",
        "Description":"",
        "Keywords":""
    },
    "Deployment Type": {
        "Content Location":"\\\\Server\\Share\\SCCM_Packages\\Software\\",
        "Install Program":"Powershell.exe -ExecutionPolicy Bypass -file Deploy-Application.ps1 -DeploymentType \"Install\"",
        "Uninstall Program":"Powershell.exe -ExecutionPolicy Bypass -file Deploy-Application.ps1 -DeploymentType \"Uninstall\"",
        "Maximum Install Time":"",
        "Estimated Install Time":""
    },
    "CollID":"A0000209",
	"Detection Method": {
		"Company Key":""
	}
}
"@

   New-Item "C:\Temp\ConfigMGR-NewApplication.json" -Force
   Set-Content "C:\Temp\ConfigMGR-NewApplication.json" $JSONContent -Force
   Start-Process Notepad++ "C:\Temp\ConfigMGR-NewApplication.json"
   $READYtoGO = Read-Host "Have you updated the JSON File? (Y)es or (N)o"

   if ($READYtoGO -ieq 'Y') {
      $Config = Get-Content "C:\temp\ConfigMGR-NewApplication.json" | ConvertFrom-Json

      $ApplicationName = $Config.Application.Name
      $AdminComment = $Config.Application.'Admin Comment'
      $Publisher = $Config.Application.Publisher
      $SoftwareVersion = $Config.Application.Version

      $SoftwareCenterName = $Config.'Software Center'.Name
      $SoftwareCenterDescription = $Config.'Software Center'.Description
      $SoftwareCenterKeywords = $Config.'Software Center'.Keywords

      $ContentLocation = $Config.'Deployment Type'.'Content Location'
      $InstallProgram = $Config.'Deployment Type'.'Install Program'
      $UninstallProgram = $Config.'Deployment Type'.'Uninstall Program'
      $MaxRunTime = $Config.'Deployment Type'.'Maximum Install Time'
      $EstRunTime = $Config.'Deployment Type'.'Estimated Install Time'

      $CollID = $Config.CollID

      $Detection = $Config.'Detection Method'.'Company Key'

      $DClause = New-CMDetectionClauseRegistryKey -Hive LocalMachine -KeyName "SOFTWARE\Company\$Detection"

      Set-Location A00:
      New-CMApplication -Name $ApplicationName -Description $AdminComment -Publisher $Publisher -SoftwareVersion $SoftwareVersion -ReleaseDate $Today -LocalizedName $SoftwareCenterName -LocalizedDescription $SoftwareCenterDescription -Keyword $SoftwareCenterKeywords

      Add-CMScriptDeploymentType -ApplicationName $ApplicationName -DeploymentTypeName "$ApplicationName Installer" -InstallationProgram $InstallProgram -ScriptContent "" -ScriptType PowerShell
      Set-CMScriptDeploymentType -ApplicationName $ApplicationName -DeploymentTypeName "$ApplicationName Installer" -ContentLocation $ContentLocation -UninstallCommand $UninstallProgram -InstallationBehaviorType InstallForSystem -InstallationProgramVisibility Normal -RequireUserInteraction $false -MaximumAllowedRunTimeMins $MaxRunTime -EstimatedRuntimeMins $EstRunTime -AddDetectionClause $DClause
      Start-CMContentDistribution -ApplicationName $ApplicationName -DistributionPointGroupName "DP Group"
      New-CMApplicationDeployment -CollectionID $CollID -DeployAction Install -DeployPurpose Available -Name $ApplicationName
      $app = Get-CMApplication -Name $ApplicationName
      Move-CMObject -InputObject $app -FolderPath A00:\Application\$Publisher
   }

   Set-Location $env:HOMEDRIVE
}