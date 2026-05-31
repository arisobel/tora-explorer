param(
  [string]$Name = "tora-explorer-caprover",
  [int]$Keep = 5
)

$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$dist = Join-Path $root "dist"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$tarName = "$Name-$stamp.tar"
$tarPath = Join-Path $dist $tarName
$stage = Join-Path ([System.IO.Path]::GetTempPath()) "$Name-$stamp"
$stageTarPath = Join-Path ([System.IO.Path]::GetTempPath()) $tarName

New-Item -ItemType Directory -Force -Path $dist | Out-Null
New-Item -ItemType Directory -Force -Path $stage | Out-Null

try {
  Copy-Item -LiteralPath (Join-Path $root "index.html") -Destination $stage
  Copy-Item -LiteralPath (Join-Path $root "data") -Destination $stage -Recurse
  Copy-Item -LiteralPath (Join-Path $root "Dockerfile") -Destination $stage
  Copy-Item -LiteralPath (Join-Path $root "nginx.conf") -Destination $stage
  Copy-Item -LiteralPath (Join-Path $root "captain-definition") -Destination $stage

  $assets = Join-Path $root "assets"
  if (Test-Path $assets) {
    Copy-Item -LiteralPath $assets -Destination $stage -Recurse
  }

  Push-Location $stage
  try {
    tar -cf "../$tarName" .
  }
  finally {
    Pop-Location
  }

  Move-Item -LiteralPath $stageTarPath -Destination $tarPath -Force

  Get-ChildItem -LiteralPath $dist -Filter "$Name-*.tar" |
    Sort-Object LastWriteTime -Descending |
    Select-Object -Skip $Keep |
    Remove-Item -Force

  Write-Host "Generated: $tarPath"
}
finally {
  if (Test-Path $stage) {
    Remove-Item -LiteralPath $stage -Recurse -Force
  }
  if (Test-Path $stageTarPath) {
    Remove-Item -LiteralPath $stageTarPath -Force
  }
}
