param(
  [int]$Port = 8080,
  [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$Root = [IO.Path]::GetFullPath($Root)
$LogPath = Join-Path $Root '.codex\local-static-server.log'
function Write-ServerLog([string]$Message) {
  try {
    $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Add-Content -LiteralPath $LogPath -Value "[$stamp] $Message"
  } catch {}
}

$server = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Parse('127.0.0.1'), $Port)

$mime = @{
  '.html' = 'text/html; charset=utf-8'
  '.htm'  = 'text/html; charset=utf-8'
  '.css'  = 'text/css; charset=utf-8'
  '.js'   = 'application/javascript; charset=utf-8'
  '.json' = 'application/json; charset=utf-8'
  '.svg'  = 'image/svg+xml'
  '.png'  = 'image/png'
  '.jpg'  = 'image/jpeg'
  '.jpeg' = 'image/jpeg'
  '.webp' = 'image/webp'
  '.ico'  = 'image/x-icon'
  '.txt'  = 'text/plain; charset=utf-8'
  '.md'   = 'text/markdown; charset=utf-8'
  '.sql'  = 'text/plain; charset=utf-8'
}

function Write-HttpResponse($Stream, [int]$StatusCode, [string]$Reason, [string]$ContentType, [byte[]]$Body) {
  $headers = @(
    "HTTP/1.1 $StatusCode $Reason",
    "Content-Type: $ContentType",
    "Content-Length: $($Body.Length)",
    "Connection: close",
    "Cache-Control: no-cache",
    "",
    ""
  ) -join "`r`n"

  $headerBytes = [Text.Encoding]::ASCII.GetBytes($headers)
  $Stream.Write($headerBytes, 0, $headerBytes.Length)
  if ($Body.Length -gt 0) {
    $Stream.Write($Body, 0, $Body.Length)
  }
}

function Text-Body([string]$Text) {
  return [Text.Encoding]::UTF8.GetBytes($Text)
}

$server.Start()
Write-ServerLog "Serving $Root at http://127.0.0.1:$Port/"
Write-Host "Serving $Root at http://127.0.0.1:$Port/"

while ($true) {
  $client = $server.AcceptTcpClient()
  try {
    $stream = $client.GetStream()
    $reader = [IO.StreamReader]::new($stream, [Text.Encoding]::ASCII, $false, 1024, $true)
    $requestLine = $reader.ReadLine()
    if ([string]::IsNullOrWhiteSpace($requestLine)) {
      Write-HttpResponse $stream 400 'Bad Request' 'text/plain; charset=utf-8' (Text-Body 'Bad request')
      continue
    }

    while ($true) {
      $line = $reader.ReadLine()
      if ($null -eq $line -or $line.Length -eq 0) { break }
    }

    $parts = $requestLine.Split(' ')
    if ($parts.Length -lt 2 -or $parts[0] -ne 'GET') {
      Write-HttpResponse $stream 405 'Method Not Allowed' 'text/plain; charset=utf-8' (Text-Body 'Method not allowed')
      continue
    }

    $urlPath = $parts[1].Split('?')[0]
    $rel = [Uri]::UnescapeDataString($urlPath).TrimStart('/')
    if ([string]::IsNullOrWhiteSpace($rel)) { $rel = 'index.html' }

    $rel = $rel -replace '/', [IO.Path]::DirectorySeparatorChar
    $path = [IO.Path]::GetFullPath([IO.Path]::Combine($Root, $rel))

    if (-not $path.StartsWith($Root, [StringComparison]::OrdinalIgnoreCase)) {
      Write-HttpResponse $stream 403 'Forbidden' 'text/plain; charset=utf-8' (Text-Body 'Forbidden')
      continue
    }

    if ([IO.Directory]::Exists($path)) {
      $path = [IO.Path]::Combine($path, 'index.html')
    }

    if (-not [IO.File]::Exists($path)) {
      Write-HttpResponse $stream 404 'Not Found' 'text/plain; charset=utf-8' (Text-Body 'Not found')
      continue
    }

    $bytes = [IO.File]::ReadAllBytes($path)
    $ext = [IO.Path]::GetExtension($path).ToLowerInvariant()
    $contentType = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { 'application/octet-stream' }
    Write-HttpResponse $stream 200 'OK' $contentType $bytes
  } catch {
    Write-ServerLog "Error: $($_.Exception.Message)"
    try {
      if ($stream) {
        Write-HttpResponse $stream 500 'Server Error' 'text/plain; charset=utf-8' (Text-Body 'Server error')
      }
    } catch {}
  } finally {
    if ($reader) { $reader.Dispose() }
    if ($client) { $client.Close() }
  }
}
