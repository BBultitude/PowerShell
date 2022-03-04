function New-MEMUserCollectionByDepartment {
    <#
    .SYNOPSIS
        Creates collections based on deparments
    .DESCRIPTION
        New-MEMDUserCollectionByDepartment creates new collections based on deparment information in \\bmd\bmdapps\BI\JamesG\Departments.csv
    .INPUTS
        None
    .OUTPUTS
        None
    .NOTES
        Version:        1.3
        Author:         Bryan Bultitude
        Creation Date:  27/07/2021
        Purpose/Change: 27/07/2021 - Bryan Bultitude - Initial script development
                        01/09/2021 - Bryan Bultitude - Fixed function name & updated function to be able to run if in A00:\
                        21/09/2021 - Bryan Bultitude - Updated Function name to be different from Configuration Module Functions
                        09/12/2021 - Bryan Bultitude - Moved Comment Based Help to top of function
    .EXAMPLE
        PS> New-MEMUserCollectionByDepartment
    #>
    $script:FolderName = "By Department"
    $script:SiteCode = 'A00'
    Set-Location $env:HOMEDRIVE\$env:HOMEPATH
    $departments = Import-Csv \\Server\Share\Departments.csv
    Import-MEMModule -SiteCode $script:SiteCode
    foreach ($department in $departments) {
        $DEPTID = ($department.DepartmentID)
        $DEPT = ($department.Department)
        $userColl = "Dept - $DEPTID - $DEPT"
        if (-not (Get-CMUserCollection -Name $Usercoll)) {
            $Response = Read-Host "
$(Get-Date):   Are you sure you want to create new Device and User collection for: `"$($userColl)`" ? (Y/N)"
            Write-Host ""
            switch ($Response) {
                Y {
                    Write-Host "$(Get-Date):   Creating User Collection `"$($userColl)`"" -ForegroundColor Green
                    $Schedule = New-CMSchedule -RecurInterval Days -RecurCount 7
                    $UColl = New-CMUserCollection -LimitingCollectionId A000021D -Name $userColl -RefreshSchedule $Schedule -Comment "All users in department $DEPTID"
                    $QueryExpression = "select SMS_R_USER.ResourceID,SMS_R_USER.ResourceType,SMS_R_USER.Name,SMS_R_USER.UniqueUserName,SMS_R_USER.WindowsNTDomain from SMS_R_User where UserGroupName = `"Company\\Dept-$DEPTID-GroupStaff_usg`""
                    Add-CMUserCollectionQueryMembershipRule -CollectionId $UColl.CollectionID -RuleName "All users in department $DEPTID" -QueryExpression $QueryExpression
                    Get-CMCollection -Name $userColl | Move-CMObject -FolderPath A00:\UserCollection\$FolderName
                    Start-Sleep -Seconds 5
                    $NewUserColl = Get-CMCollection -Name $userColl
                    $UserCollID = $NewUserColl.CollectionID
                    Write-Host "$(Get-Date):   Creating Device Collection `"$("$userColl ($UserCollID)")`"" -ForegroundColor Green
                    $Schedule = New-CMSchedule -RecurInterval Days -RecurCount 7
                    $DColl = New-CMDeviceCollection -LimitingCollectionId A00000CD -Name "$userColl ($UserCollID)" -RefreshSchedule $Schedule -Comment "All devices for users in department $DEPTID"
                    $QueryExpression = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ResourceId in (select resourceid from SMS_UserMachineRelationship JOIN SMS_FullCollectionMembership ON LOWER(SMS_UserMachineRelationship.UniqueUserName) = LOWER(SMS_FullCollectionMembership.SMSID)  where MS_UserMachineRelationship.UniqueUserName is not null AND SMS_UserMachineRelationship.Types=1 AND SMS_FullCollectionMembership.CollectionID=`"$UserCollID`")"
                    Add-CMDeviceCollectionQueryMembershipRule -CollectionId $DColl.CollectionID -RuleName "All devices for users in department $DEPTID" -QueryExpression $QueryExpression
                    Get-CMCollection -Name "$userColl ($UserCollID)" | Move-CMObject -FolderPath A00:\DeviceCollection\$FolderName


                }
                N {
                    Write-Host "$(Get-Date):   User Collection `"$($userColl)`" not being created as requested, skipping it." -ForegroundColor DarkYellow
                    Write-Host "$(Get-Date):   Device Collection `"$("$userColl ($UserCollID)")`" not being created as requested, skipping it." -ForegroundColor DarkYellow 
                }
                Default {
                    Write-Host "$(Get-Date):   User Collection `"$($userColl)`" not being created due to no valid response, skipping it." -ForegroundColor Red
                    Write-Host "$(Get-Date):   User Collection `"$("$userColl ($UserCollID)")`" not being created due to no valid response, skipping it." -ForegroundColor Red 
                }
            }
        }
        else {
            Write-Host "$(Get-Date):   Department Collection `"$($userColl)`" already exists, skipping it." -ForegroundColor DarkYellow
        }
    }
    Set-Location $env:HOMEDRIVE\$env:HOMEPATH
}