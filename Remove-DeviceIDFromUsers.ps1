<#
.Synopsis
   This script will loop through users in the CSV file and REMOVE the device ID's.
.DESCRIPTION
   This script will loop through users in the CSV file and REMOVE the device ID's from each individual (not block, REMOVE!).
.EXAMPLE
   .\Remove-DeviceIDFromUsers.ps1 -CsvFileLocation <location_of_your_CSV_File>
.EXAMPLE
   .\Remove-DeviceIDFromUsers.ps1 (if no parameters are entered, you will be prompted for them)
.INPUTS
   Csv File
.OUTPUTS
   None
.NOTES
   - The input file (your Csv file) MUST contain the 2 column headers named EmailAddress and Identifier
   - To verify a device ID (identifier) has been added to a user, run the cmdlet:
     => Get-CASMailbox -Identity <user@mydomain.com> | select Name, ActiveSyncAllowedDeviceIDs
#>
[CmdletBinding()]
param(    
    [Parameter(Mandatory=$true,HelpMessage="This is the location of the CSV file containing all the users",Position=1)] 
    [string]$CsvFileLocation
)
#Connect to O365
$cred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection
Import-PSSession $Session

Write-Host "Connected to Exchange Online." -f Green
Write-Host "Now processing... Be patient." -f Gray

#Declare Variable
$Users = Import-Csv $CsvFileLocation

foreach($user in $Users){
    Set-CASMailbox -Identity $user.EmailAddress -ActiveSyncAllowedDeviceIDs @{Remove=$user.Identifier}
}

#Close the EXO connection
Remove-PSSession $Session