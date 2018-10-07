<#
.SYNOPSIS

Convert a string to Base64.

.DESCRIPTION

Takes a string and converts it to a Base64 encoded string.
Useful for the authority section of a URL e.g.

http://username:password@hostname/path/file.csv

.PARAMETER StringToEncode

Specifies the string.

.OUTPUTS

A Base64 encoded string.

.EXAMPLE

C:\PS> .\encode.ps1 -StringToEncode "username:password"
Encoded String: dXNlcm5hbWU6cGFzc3dvcmQ=

#>

Param(
  [Parameter(Mandatory=$True)][string]$StringToEncode
)

$EncodedString=[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($StringToEncode))

Write-Host "Encoded String:" $EncodedString