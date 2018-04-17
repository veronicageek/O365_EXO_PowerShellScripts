<#
.Synopsis
   This script will loop through all users in the tenant and RETRIEVE the status of each user's device ID (allowed to sync / blocked from syncing).
.DESCRIPTION
   This script will loop through all users in the tenant, RETRIEVE the device ID's allowed/blocked to sync from each individual, and create a report 
   that will be located on the desktop. The script will also REMOVE ANY DUPLICATES with regards to the PrimarySmtpAddress property.
.EXAMPLE
   .\RetrieveDeviceIDs_ForTenant.ps1
#>

#Connect to O365
$cred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection
Import-PSSession $Session

Write-Host "Connected to Exchange Online." -f Gray
Write-Host "Now processing... Be patient." -f Yellow

#Declare Variable
$Users = Get-CASMailbox
$OutputFile = "C:\users\$env:USERNAME\Desktop\Report_DeviceIDsForTenant.csv"

$Results = @()
foreach($user in $Users){
    $Results += Get-CASMailbox -Identity $user.UserPrincipalName | select PrimarySmtpAddress, @{n='AllowedDeviceIDs';e={$_.ActiveSyncAllowedDeviceIDs -join ";"}},@{n='BlockedDeviceIDs';e={$_.ActiveSyncBlockedDeviceIDs -join ";"}} 
}

$Results | Sort-Object -Unique -Property PrimarySmtpAddress | Export-Csv -Path $OutputFile -NoTypeInformation

Remove-PSSession $Session
