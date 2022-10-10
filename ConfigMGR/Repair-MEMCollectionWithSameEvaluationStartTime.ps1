Function Repair-MEMCollectionWithSameEvaluationStartTime {
    <#
    .SYNOPSIS
       Fix Configuration Manager Collections with same start time
    .DESCRIPTION
       Fix Configuration Manager Collections with same date and start time by staggering by 1 minute. Collections will be on a 7 day evaluation schedule
    .PARAMETER Date
       Initial start date in DD/MM/YYYY format. Can not be earlier than 03/02/1970
    .PARAMETER Collections
       Collection Names that will be updated
    .INPUTS
       N/A
    .OUTPUTS
       N/A
    .NOTES
       Version:        1.0
       Author:         Bryan Bultitude
       Creation Date:  10/10/2022
       Purpose/Change: 10/10/2022 - Bryan Bultitude - Initial script development
    .EXAMPLE
       PS> Repair-MEMCollectionWithSameEvaluationStartTime -Date "03/02/1970" -Collections "BIOS Testing","User - Mark"
    #>
    param (
        [Parameter(Mandatory = $true)]$Date,
        [Parameter(Mandatory = $true)]$Collections
    )
    Import-MEMModule A00
    $H = 12
    $M = 0
    $AMPM = "AM"
    foreach ($Coll in $Collections) {
        if ($M -le 58) {
            $M ++
        }
        elseif ($M -eq 59) {
            switch ($H) {
                12 { $H = 1 }
                11 {
                    $H = 12
                    switch ($AMPM) {
                        AM { $AMPM = "PM" }
                        PM { $AMPM = "AM" }
                    }
                }
                Default {}
            }
            $M = 0
        }
        $MM = "{0:D2}" -f $M
        $HH = "{0:D2}" -f $H
        $Time = "$HH`:$MM $AMPM"
        $Schedule = New-CMSchedule -Start "$Date $Time" -RecurInterval Days -RecurCount 7 -DurationCount 0 -DurationInterval Days
        $Collection = Get-CMCollection -Name $Coll
        if ($Collection -ne $null ){
            Set-CMCollection -CollectionId $Collection.CollectionID -RefreshSchedule $Schedule -RefreshType Periodic        
        }
        Else { Write-Host "Collection `"$COLL`" couldn't be found"}
    }
}