$EmailAddresses = Get-Content C:\Temp\addUsersToDL\EmailAddresses.txt
$DistributionList = "Sales_Users"

Foreach ($EmailAddress in $EmailAddresses) {
    $ADObjects = Get-ADObject -Filter {Mail -Like $EmailAddress} -Properties Mail,DistinguishedName
    
    Foreach ($ADObject in $ADObjects) {
        Set-ADGroup -Identity $DistributionList -Add @{'Member'=$ADObject.DistinguishedName}
        }
    }
