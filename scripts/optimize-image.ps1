<#
.SYNOPSIS
  Redimensiona e comprime uma imagem para uso no Torá Explorer.
  Mesmo fluxo usado na sarça ardente (3 MB PNG -> ~420 KB JPG @ 1024px).

.EXAMPLE
  pwsh scripts/optimize-image.ps1 -In "C:\Downloads\foto.png" -Out "assets/user/ester-banquete.jpg"

.PARAMETER In       Caminho da imagem de origem (png/jpg/webp...).
.PARAMETER Out      Caminho de saída .jpg. Se omitido, usa o nome de In com .jpg.
.PARAMETER MaxEdge  Maior aresta em px (padrão 1024). A proporção é preservada.
.PARAMETER Quality  Qualidade JPEG 1-100 (padrão 85).
#>
param(
  [Parameter(Mandatory = $true)][string]$In,
  [string]$Out,
  [int]$MaxEdge = 1024,
  [int]$Quality = 85
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$src = (Resolve-Path $In).Path
if (-not $Out) { $Out = [System.IO.Path]::ChangeExtension($src, '.jpg') }

$img = [System.Drawing.Image]::FromFile($src)
try {
  $scale = [Math]::Min(1.0, $MaxEdge / [Math]::Max($img.Width, $img.Height))
  $w = [int][Math]::Round($img.Width * $scale)
  $h = [int][Math]::Round($img.Height * $scale)

  $bmp = New-Object System.Drawing.Bitmap $w, $h
  try {
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.DrawImage($img, 0, 0, $w, $h)
    $g.Dispose()

    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
    $ep = New-Object System.Drawing.Imaging.EncoderParameters 1
    $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [int64]$Quality)
    $bmp.Save($Out, $codec, $ep)
  } finally { $bmp.Dispose() }
} finally { $img.Dispose() }

$kb = [Math]::Round((Get-Item $Out).Length / 1KB)
Write-Host "OK: $Out  (${w}x${h}, ${kb} KB)"
