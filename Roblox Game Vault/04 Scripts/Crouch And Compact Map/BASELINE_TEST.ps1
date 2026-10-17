$ErrorActionPreference='Stop'
$b=Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot 'BASELINE.json') | ConvertFrom-Json
$f=Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot 'BEFORE_FLOORS.json') | ConvertFrom-Json
if($b.snapshot.audioVolume -ne .25){throw 'Unexpected baseline music'}
$c=$b.snapshot.sources | Where-Object {$_.path -eq 'ReplicatedStorage.GameplayPresentation.MovementClient'}
if($c.source.Contains('function M.Crouch')){throw 'Baseline already contained crouch'}
$west=$b.snapshot.boundary | Where-Object {$_.name -eq 'WestSolid'}
$east=$b.snapshot.boundary | Where-Object {$_.name -eq 'EastSolid'}
$north=$b.snapshot.boundary | Where-Object {$_.name -eq 'NorthSolid'}
$south=$b.snapshot.boundary | Where-Object {$_.name -eq 'SouthSolid'}
$width=($east.cf[0]-$east.size[0]/2)-($west.cf[0]+$west.size[0]/2)
$depth=($south.cf[2]-$south.size[2]/2)-($north.cf[2]+$north.size[2]/2)
if($width -ne 534 -or $depth -ne 300 -or $f.pairs -ne 12){throw 'Baseline geometry mismatch'}
Write-Output 'BASELINE PASS: music=0.25; crouch absent; inner footprint=534x300; detected floor overlaps=12'

