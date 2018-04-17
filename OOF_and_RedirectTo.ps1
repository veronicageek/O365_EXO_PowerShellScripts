<#
.Synopsis
   This script will set an Out-of-Office message, REDIRECT emails from primary mailbox, and prevent loop from the emails coming back if the external address sends an email.
.DESCRIPTION
   This script will set an Out-of-Office message, REDIRECT emails from primary mailbox ("$user.mailbox" coming from CSV file), and prevent loop from the emails coming back 
   if the external address ($user.ForwardTo in CSV file) sends an email. 
.EXAMPLE
   .\OOF_and_RedirectTo.ps1 -CsvFileLocation <CsvFile_Location>
.EXAMPLE
   .\OOF_and_RedirectTo.ps1 (if no parameters are entered, you will be prompted for them)
.INFORMATION
    Forward or Redirect messages - MSFT Support article
    https://support.office.com/en-gb/article/Forward-and-redirect-email-automatically-9f124e4a-749e-4288-a266-2d009686b403
#>
[CmdletBinding()]
param(    
    [Parameter(Mandatory=$true,HelpMessage="This is the location of the CSV file containing all the users",Position=1)] 
    [string]$CsvFileLocation,

    [Parameter(Mandatory=$true,HelpMessage="This is the location of the CSV file containing all the users",Position=2)] 
    [string]$OOFMessagePath
)
#Enter O365 credentials
$cred = Get-Credential

#Connect to EXO
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection
Import-PSSession $Session

Write-Host "Connected to Exchange Online." -f Green

#Declare Variable
$Users = Import-Csv $CsvFileLocation
$sender = ($Users).ForwardTo
$OOFmsg = Get-Content $OOFMessagePath

foreach($user in $Users){

   Write-Host ">> Setting up mailbox for" $user.UserPrincipalName -f Gray

     #Set Out-of-Office reply
     Set-MailboxAutoReplyConfiguration -Identity $user.mailbox -AutoReplyState Enabled -ExternalAudience None -InternalMessage $OOFmsg -ExternalMessage $null
     Write-Host "Out-of-Office message set" -f Yellow

     #Redirect emails 
     New-InboxRule "ForwardToChrisDaniels" -Mailbox $User.Mailbox -RedirectTo $User.ForwardTo -ExceptIfFrom $sender -MarkAsRead $false -Force
     Write-Host "New inbox rule created" -f Yellow

}

Remove-PSSession $Session
