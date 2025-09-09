# Zip the Custom directory before running terraform
$source = "$PSScriptRoot\\Custom"
$destination = "$PSScriptRoot\\Custom.zip"
if (Test-Path $destination) { Remove-Item $destination }
Compress-Archive -Path "$source\\*" -DestinationPath $destination