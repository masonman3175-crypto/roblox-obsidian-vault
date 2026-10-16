#!/usr/bin/env pwsh
param(
  [Parameter(Mandatory=$true)][string]$TargetFile,
  [Parameter(Mandatory=$true)][string]$BaselineFile
)
Copy-Item -LiteralPath $BaselineFile -Destination $TargetFile -Force
$targetHash=(Get-FileHash -LiteralPath $TargetFile -Algorithm SHA256).Hash
$baselineHash=(Get-FileHash -LiteralPath $BaselineFile -Algorithm SHA256).Hash
if ($targetHash -ne $baselineHash) { exit 1 }
Write-Output "restored: $TargetFile"
