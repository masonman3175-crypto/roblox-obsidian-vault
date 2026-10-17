$ErrorActionPreference='Stop'
$b=Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot 'BASELINE.json') | ConvertFrom-Json
if($b.sounds.Count -ne 0) { throw 'Unexpected pre-existing catalog sounds' }
if(@($b.sources | Where-Object { $_.path -like '*AudioPresentation*' }).Count -ne 0) { throw 'Audio bootstrap existed at baseline' }
if($b.sources.Count -ne 9) { throw 'Protected-source snapshot incomplete' }
Write-Output 'BASELINE PASS: 9 existing sources preserved; no general audio bootstrap or background music in snapshot'

