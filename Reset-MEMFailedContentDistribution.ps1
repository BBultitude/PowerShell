function Reset-MEMFailedContentDistribution {
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