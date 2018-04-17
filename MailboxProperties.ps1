<#
.Synopsis
   This script will loop through all users in the tenant to retrieve some mailbox properties.
.DESCRIPTION
   This script will loop through all users in the tenant and create a CSV file with some mailbox properties (Primary SMTP address, Archive status, Server name).
   Results will be exported on the desktop to a .CSV file called "MailboxProps.csv"
.EXAMPLE
   .\MailboxProperties.ps1 
#>

#Connect to O365 and EXO
$cred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection
Import-PSSession $Session

Write-Host "Connected to Exchange Online." -f Green

# Check if the below .CSV file name exists - If yes, delete it.
Write-Host "Checking if an Output file already exists..." -f Gray
$OutputFile="C:\users\$env:USERNAME\desktop\MailboxProps.csv"
    If (test-Path $OutputFile)
        {
		   Write-Host "Output file with same name found - Deleting it now..." -f Yellow
           Remove-Item $OutputFile
        }
    Else
        {
		   Write-Host "No output file found - OK." -f Gray
        }


Write-Host "Processing... Be patient." -f DarkCyan

$UserMlbxes = Get-mailbox -ResultSize Unlimited

#Loop through each user in the tenant & Export the results on the desktop
$Results = @()
foreach ($Mailbox in $UserMlbxes)
    {
      $Results += Get-Mailbox -Identity $Mailbox.Name | Select-Object UserPrincipalName, PrimarySmtpAddress, ArchiveStatus, ServerName 
    } 
 
 $Results | Export-Csv -Path "C:\users\$env:USERNAME\desktop\MailboxProps.csv"

Remove-PSSession $Session
   