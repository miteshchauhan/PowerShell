#===========================================================================================================
# Script will remove users that are disabled and have not been logged into for the specified amount of days.
#===========================================================================================================

$OUs = "OU=Laptop_Users,OU=UK_LON,OU=domain,DC=domain,DC=com","OU=Laptop_Users,OU=UK_MAN,OU=domain,DC=domain,DC=com"
$days = 365
$LogfileLocation = "C:\Temp\UsersDeleted-$date.txt"

$Users = Foreach ($OU in $OUs) { Get-ADUser -Filter {Enabled -eq $FALSE} -SearchBase $OU -Properties Name,SamAccountName,Office,LastLogonDate | Where-Object {($_.LastLogonDate -lt (Get-Date).AddDays(-$days)) -and ($_.LastLogonDate -ne $NULL)} }

Clear-Host
Write-Output "You're about to DELETE the following user accounts. Are you sure you want to do this?"

$UsersFormatted = $Users | Select-Object Name, Office, LastLogonDate | Format-Table
Write-Output $UsersFormatted

$ConfirmDelete = Read-Host "I want to delete these user accounts. Y/N"

$date = get-date -Format dd.MM.yyyy

if ( $ConfirmDelete -eq "y") { 
    ForEach ($User in $Users) {
        $Username = ($User.Name)
        Write-Output $Username" Deleted" >> $LogfileLocation
        Remove-ADUser -Identity $User -Confirm:$false
        Write-Host ($User.Name)" Removed"
        Start-Sleep -Seconds 1
    }
}