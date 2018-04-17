<#
.Synopsis
   This script export SMTP email addresses for users in CSV file.
.DESCRIPTION
   This script export SMTP addresses into a file, for the users contained in your CSV file. 
.EXAMPLE
   .\Get-PrimarySMTPAddressFromCSVFile.ps1 -CsvFileLocation <CsvFile_Location> -OutputFile <c:\MyOutputFile.csv>
.EXAMPLE
   .\Get-PrimarySMTPAddressFromCSVFile.ps1 (if no parameters are entered, you will be prompted for them)
#>
[CmdletBinding()]
param(    
    [Parameter(Mandatory=$true,HelpMessage="This is the location of the CSV file containing all the users",Position=1)] 
    [string]$CsvFileLocation,
    [Parameter(Mandatory=$true,HelpMessage="This will be the full path of the report the script will create",Position=2)] 
    [string]$OutputFile
)
#Connect to EXO
$Cred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Cred -Authentication Basic -AllowRedirection
Import-PSSession $Session

Write-Host "Connected to Exchange Online" -f Gray
Write-Host "Now processing. Be patient..." -f Yellow

#Import CSV file
$Users = Import-Csv $CsvFileLocation

#Loop through each user & Export the results into the Output File
$Results = @()
foreach ($user in $Users)
    {
        $Results += (Get-Mailbox -Identity $user.UserPrincipalName) | select UserPrincipalName,PrimarySmtpAddress
    }

 $Results | Export-Csv -Path $OutputFile

 Remove-PSSession $Session
