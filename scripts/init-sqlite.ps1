param(
  [string]$DatabasePath = "db/tora-explorer.sqlite",
  [switch]$Recreate
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$dbPath = if ([System.IO.Path]::IsPathRooted($DatabasePath)) {
  $DatabasePath
} else {
  Join-Path $root $DatabasePath
}

$dbDir = Split-Path -Parent $dbPath
if (-not (Test-Path $dbDir)) {
  New-Item -ItemType Directory -Path $dbDir | Out-Null
}

if ($Recreate -and (Test-Path $dbPath)) {
  $resolvedRoot = (Resolve-Path $root).Path
  $resolvedDbDir = (Resolve-Path $dbDir).Path
  if (-not $resolvedDbDir.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to recreate database outside the repository: $dbPath"
  }
  Remove-Item -LiteralPath $dbPath -Force
}

$sqlite = (Get-Command sqlite3 -ErrorAction Stop).Source
$migrationDir = Join-Path $root "db/migrations"
$migrations = Get-ChildItem $migrationDir -Filter "*.sql" | Sort-Object Name

if (-not $migrations) {
  throw "No migrations found in $migrationDir"
}

foreach ($migration in $migrations) {
  $version = [System.IO.Path]::GetFileNameWithoutExtension($migration.Name)
  $schemaTableExists = & $sqlite $dbPath "SELECT name FROM sqlite_master WHERE type='table' AND name='schema_migrations';"
  if ($schemaTableExists) {
    $alreadyApplied = & $sqlite $dbPath "SELECT 1 FROM schema_migrations WHERE version='$version' LIMIT 1;"
    if ($alreadyApplied) {
      Write-Host "Skipping $($migration.Name)"
      continue
    }
  }

  Write-Host "Applying $($migration.Name)"
  & $sqlite $dbPath ".read '$($migration.FullName.Replace("'", "''"))'"
  if ($LASTEXITCODE -ne 0) {
    throw "sqlite3 failed while applying $($migration.Name)"
  }
}

Write-Host "SQLite database ready: $dbPath"
