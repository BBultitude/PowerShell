function Reset-MEMFailedContentDistribution {
    <#
    .SYNOPSIS
       Redistributed Content
    .DESCRIPTION
       Redistributed Content that has failed to distributed to any DP
    .INPUTS
       N/A
    .OUTPUTS
       N/A
    .NOTES
       Version:        1.1
       Author:         Bryan Bultitude
       Creation Date:  24/09/2021
       Purpose/Change: 24/09/2021 - Bryan Bultitude - Initial script development
                       09/12/2021 - Bryan Bultitude - Added Commments Based Help
    .EXAMPLE
       PS> Reset-MEMFailedContentDistribution
    #>
    $Server = "SERVER"
    $Namespace = "root\sms\site_A00"
    $strQuery = "Select Name,PackageID from SMS_DistributionDPStatus where MessageState > 2"
    $REFRESHED = @()
    Get-WmiObject -Query $strQuery -Namespace $Namespace -ComputerName $Server | ForEach-Object {
        $ServerName = $_.Name
        $ServerName = $ServerName.ToUpper()
        $PackageID = $_.PackageID
        $strQuery = "select * from SMS_DistributionPoint where PackageID = '$PackageID'"
        $PackageDPGroup = Get-WmiObject -Query $strQuery -Namespace $Namespace -ComputerName $Server
        foreach ($PackageDP in $PackageDPGroup) {
            $NalPath = $PackageDP.ServerNalPath
            if ($NalPath.ToUpper().Contains("$ServerName")) {
                $Error.Clear()
                $PackageDP.RefreshNow = $true
                $PackageDP.Put()
                $REFRESHED += "Package $PackageID Refreshed on $ServerName"
            }
        }
    }
    Clear-Host
    $REFRESHED
}