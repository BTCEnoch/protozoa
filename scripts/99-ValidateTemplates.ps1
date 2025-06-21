# 99-ValidateTemplates.ps1 – fails if any script still contains here-string inline TS
[CmdletBinding()]param([string]$ProjectRoot=$PWD)
$violations = @()
Get-ChildItem -Path (Join-Path $ProjectRoot 'scripts') -Filter '*.ps1' -Recurse | ForEach-Object {
  $text = Get-Content $_.FullName -Raw
  if ($text -match "@'" ) { $violations += $_.Name }
}
if ($violations.Count -gt 0) {
  Write-Error "Inline here-strings found in scripts: $($violations -join ', ')"
  exit 1
}
Write-Host "Template validation passed" -ForegroundColor Green