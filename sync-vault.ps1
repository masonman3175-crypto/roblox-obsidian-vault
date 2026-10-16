param(
  [string]$Vault = (Split-Path -Parent $MyInvocation.MyCommand.Path)
)
$ErrorActionPreference = 'Stop'
Set-Location $Vault
Write-Host 'Pulling latest vault changes...'
git pull --rebase origin main
Write-Host 'Committing local vault changes...'
git add -A
if (git diff --cached --quiet) { Write-Host 'Nothing new to commit.' } else { git commit -m "Sync Obsidian vault" }
Write-Host 'Pushing vault changes...'
git push origin main
Write-Host 'Vault sync complete.'
