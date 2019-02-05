#======================================================================
# This will generate a random password for every user in a specified OU
#======================================================================

# Create function to generate random characters
function Get-RandomCharacters($length, $characters) {
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs=""
    return [String]$characters[$random]
}

#Set variables
$passwordLength = 8
$passwordCharacters = 'abcdefghiklmnoprstuvwxyz1234567890'
$OU = "OU=Laptop_Users,OU=UK_MAN,OU=domain,DC=domain,DC=com"
$ExportLocation = "Passwords_MAN.csv"

$Usernames = $()
$TestFilePasswords = Test-Path $ExportLocation

If ($TestFilePasswords -eq $false) {
    Write-Host "Generating Username list..."
    $Usernames = Get-ADUser -SearchBase $OU -Filter * | Select-Object GivenName, Name, SamAccountName 
    Write-Host "Generating Passwords..."
    Add-Content -Path $ExportLocation -Value '"Firstname","Name","Username","Password"'
}

Foreach ($Username in $Usernames) {
    $RandomCharacters = Get-RandomCharacters -length $passwordLength -characters $passwordCharacters
    $Password = "Welcome" + $RandomCharacters + "!"
    $People = @()
    $People += "`"$($Username.GivenName)`",`"$($Username.Name)`",`"$($Username.SamAccountName)`",`"$($Password)`""
    $People | Add-Content -Path $ExportLocation
}