Function Find-MEMAppSupersedenceIssues {
    <#
    .SYNOPSIS
       Finds supersedence issue
    .DESCRIPTION
       Finds apps that have supersedence issue due to superseded app being removed. Typically by PatchMyPC
    .INPUTS
       N/A
    .OUTPUTS
       N/A
    .NOTES
       Version:        1.0
       Author:         Bryan Bultitude
       Creation Date:  15/03/2022
       Purpose/Change: 15/03/2022 - Bryan Bultitude - Initial script development
                       04/05/2022 - Bryan Bultitude - Removed search for IsSuperseding -eq "True" as only True if deployed, added search for superseeded app being distributed, changed initial application search to be alphabetical, added additional text to write-host.
    .EXAMPLE
       PS> Find-MEMAppSupersedenceIssues
    #>
    Import-MEMModule A00
    $Applications = Get-CMApplication -Fast | Sort-Object -Property LocalizedDisplayName
    $x = $Applications.Count
    $i = 0
    Foreach ($Application in $Applications) {
        try {
            $app = Get-CMApplication -Name $($Application.LocalizedDisplayName)
            $AppMgmtDigest = ([xml]$App.SDMPackageXML).AppMgmtDigest
            $SupersedeInfo = $AppMgmtDigest.DeploymentType.Supersedes.DeploymentTypeRule
            Foreach ($SI in $SupersedeInfo) {
                $CurrentSI = ([xml]$si.InnerXml).DeploymentTypeIntentExpression.DeploymentTypeApplicationReference
                $supersedeAPP = "$($CurrentSI.AuthoringScopeId)/$($CurrentSI.LogicalName)"
                $OldApp = ""
                Foreach ($AllAPPS in $Applications) {
                    If ($supersedeAPP -eq $($AllAPPS.ModelName)) {
                        $OldApp = $AllAPPS.LocalizedDisplayName
                    }
                }
                If ($OldApp -eq "") {
                    Write-Host "Application has issue: $($Application.LocalizedDisplayName)
Superseded App: $supersedeapp
To fix manually remove the supersededapp that has been deleted from `"$($Application.LocalizedDisplayName)`"
" 
                }
                elseif ($OldApp -ne "") {
                    $OldApp = Get-CMApplication -Name $AllAPPS.LocalizedDisplayName
                    $DistributionStatus = Get-CMDistributionStatus -Id $OldApp.PackageID
                    if ($($DistributionStatus.Targeted) -lt 1 ) {
                        Write-Host "Application has issue: $($Application.LocalizedDisplayName)
Superseded App: $($OldApp.LocalizedDisplayName) isn't distributed to any Distribution points
To fix run the following command: `"Start-CMContentDistribution -ApplicationName `"$($OldApp.LocalizedDisplayName)`" -DistributionPointGroupName `"BMD Global DP Group`"`"
"
                    }
                }   
            }
            $i += 1
            Write-Progress -activity "Finding Supersedence Issues - Overall Progress: $([Math]::Round(($i / $x) * 100,2))%" -status "Working on $($Application.LocalizedDisplayName)" -PercentComplete (($i / $x) * 100)
        }
        catch {
            #$_
        }
    
    }
}