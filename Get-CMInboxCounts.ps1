Function Get-CMInboxCounts {
   $server = "SERVERNAME"
   $site = "A00"
   $SCCMInboxesDir = "\\$server\sms_$site\inboxes"
   $items = Get-ChildItem -Name $SCCMInboxesDir | Where-Object { !$_.PSIsContainer }
   $cmInbox = @{}
   foreach ($item in $items) {
      $ifolders = "$SCCMInboxesDir\$item"
      $numbers = Get-ChildItem $ifolders -Recurse | Where-Object { $_.PSIsContainer -eq $false } | Measure-Object -Property length -Sum
      $ifolders = "$SCCMInboxesDir\$item"
      $tnumber = $numbers.count
      $cmInbox.Add($item, $tnumber)
   }
   $cmInbox.GetEnumerator() | Sort-Object -Property Value -Descending | Out-GridView -Title "Configuration Manager Inbox Counts"
   <#
    .SYNOPSIS
       Display Configuration Manager Inbox file count.
    .DESCRIPTION
       Display Configuration Manager Inbox file count to help with quick fault finding of potential backlogs.
    .INPUTS
       N/A
    .OUTPUTS
       N/A
    .NOTES
       Version:        1.0
       Author:         Bryan Bultitude
       Creation Date:  21/09/2021
       Purpose/Change: Initial script development
    .EXAMPLE
       PS> Get-CMInboxCounts
    #>
}