#============================================================================================
# Script will copy files with a last write time longer than x days to a spectfied destination
# will then remove these files from source
# will then remove ANY empty containers in the path
#============================================================================================

# variables
$days = 1095
$sourcePath = "C:\Some\Path"
$destinationPath = "E:\Some\Path"

$date = (Get-Date).AddDays(-$days)

# Copy files older than the days specified to destination
Get-ChildItem -Path $sourcePath -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $date } | Copy-Item -Destination $destinationPath -Recurse -Container

# Remove the files once copy completes
Get-ChildItem -Path $sourcePath -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $date } | Remove-Item -Recurse -Force

# Remove all empty folders once completed
Get-ChildItem -Path $sourcePath -Recurse -Force | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null } | Remove-Item -Force -Recurse