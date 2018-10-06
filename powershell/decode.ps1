<#
.SYNOPSIS

Convert a string to plain text.

.DESCRIPTION

Takes a Base64 encoded string and converts it back to plain text.

.PARAMETER EncodedString

Specifies the string.

.OUTPUTS

A string, that was once a Base64 encoded string.

.EXAMPLE

C:\PS> .\decode.ps1 -EncodedString "dXNlcm5hbWU6cGFzc3dvcmQ="
Decoded String: username:password

#>

Param(
  [Parameter(Mandatory=$True)][string]$EncodedString
)

$DecodedString=[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($EncodedString))

Write-Host "Decoded String:" $DecodedString