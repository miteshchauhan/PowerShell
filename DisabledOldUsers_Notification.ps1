#===================================================================================================================================
# Script will look in specified OUs for users that have been disabled for X amount of days and send an email containing these users.
#===================================================================================================================================

$OUs = "OU=Laptop_Users,OU=UK_LON,OU=domain,DC=domain,DC=com","OU=Laptop_Users,OU=UK_MAN,OU=domain,DC=domain,DC=com"
$days = 365
$Users = Foreach ($OU in $OUs) { Get-ADUser -Filter {Enabled -eq $FALSE} -SearchBase $OU -Properties Name,SamAccountName,Office,LastLogonDate | Where-Object {($_.LastLogonDate -lt (Get-Date).AddDays(-$days)) -and ($_.LastLogonDate -ne $NULL)} }
$usersFormatted = $Users | Sort-Object LastLogonDate | Select-Object Name,SamAccountName,Office,LastLogonDate
$locationOfPurgeScript = "C:\temp\SOMESCRIPT.ps1"
$hostname = hostname

# Email Settings
$emailSMTPServer = "smtpaddress.domain.com"
$emailFromAddress = "noreply@domain.com"
$emailToAddress = "distributionlist@domain.com"
$emailSubject = "Disabled users not logged on for longer than one year"
$emailHeader = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {color:white;border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {text-align:center;border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@
$emailBody = @"
<br>
Disabled users logged on longer than one year ago.<br>
<br>
$($htmlUsers)
<br>
<br>
Please run the purge user script $($locationOfPurgeScript) located on $($hostname)
"@


if($usersFormatted -ne $null){
    $htmlUsers = $usersFormatted | ConvertTo-Html -Head $emailHeader    
    Send-MailMessage -from $emailFromAddress -to $emailToAddress -subject $emailSubject -BodyAsHtml $emailBody -SmtpServer $emailSMTPServer
}

$usersFormatted = $null