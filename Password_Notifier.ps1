#===========================================================
# Email users to inform their password will expire in X days
#===========================================================

# Variables
$testMode = 0
$testEmailAddress = "testeremailaddress@domain.com"
$notifyDays = 1,5,10,15
$helpdeskPhoneNumber = "+441234567890"
$link = "https://linkToInstructionsToChangePassword.domain.com"
$OUs = "OU=Laptop_Users,OU=UK_LON,OU=domain,DC=domain,DC=com","OU=Laptop_Users,OU=UK_MAN,OU=domain,DC=domain,DC=com"

# Email Variables
$EmailSMTPAddress = "smtpaddress.domain.com"
$EmailFromAddress = "noreply@domain.com"

foreach ($day in $notifyDays) {

    $date = (Get-Date).AddDays($day).ToString('dd/MM/yyyy')

    $users = foreach ($OU in $OUs) {
        Get-ADUser -SearchBase $OU -Filter {(Enabled -eq $True) -and (PasswordNeverExpires -eq $False) } -Properties Givenname,msDS-UserPasswordExpiryTimeComputed,mail | Select-Object Givenname,mail,@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed").ToString('dd/MM/yyyy')}} | Where-Object { $_.ExpiryDate -eq $date}
    }

    foreach ($user in $users) {
    
    if ($day -eq 1){$days = "day"} else {$days = "days"}

        $body = @"

Hi $($user.givenname),<br>
<br>

Your Windows user password is due to expire and will need to be changed in $day $days, to avoid any issues please change your password before $($date).<br>
<br>
If you need any assistance please refer to the following guide $($link) or alternatively please contact the helpdesk on $($helpdeskPhoneNumber).<br>
<br>
Regards,
<br>
IT Department<br>
<br>
"@

$subject = "Your Windows user password will need to be changed in $day $days"

if ($testMode -eq 1) {
    Send-MailMessage -from $EmailFromAddress -to $testEmailAddress -subject $subject -BodyAsHtml $body -SmtpServer $EmailSMTPAddress
    } else {
    Send-MailMessage -from $EmailFromAddress -to $($user.mail) -subject $subject -BodyAsHtml $body -SmtpServer $EmailSMTPAddress
    }

    }

}