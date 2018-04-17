<#
.Synopsis
 This script will loop through users in the CSV file and assign the device ID's
.DESCRIPTION
 This script will loop through users in the CSV file and assign the device ID's to each individual.
 Your .CSV file will need to contain at least the following headers:
    ** EmailAddress
    ** Identifier

 To verify a device ID (identifier) has been added to a user, run the cmdlet:
     => Get-CASMailbox -Identity <user@mydomain.com> | select Name, ActiveSyncAllowedDeviceIDs

.EXAMPLE
   .\AddDeviceID.ps1 -CsvFileLocation <location_of_the_CSV_File>
.EXAMPLE
   .AddDeviceID.ps1  (if no parameters are entered, you will be prompted for them)
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

Write-Host "Connected to Exchange Online." -f Gray
Write-Host "Now processing... Be patient." -f Yellow

#Declare Variable
$Users = Import-Csv $CsvFileLocation

#Add the Identifier to the users
foreach($user in $Users){
    Set-CASMailbox -Identity $user.EmailAddress -ActiveSyncAllowedDeviceIDs @{Add=$user.Identifier}
}

Remove-PSSession $Session