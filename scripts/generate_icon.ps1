# Generates a minimal black & white app icon for MonoDiary.
Add-Type -AssemblyName System.Drawing

$size = 1024
$bmp = New-Object System.Drawing.Bitmap($size, $size)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear([System.Drawing.ColorTranslator]::FromHtml("#F2F0EA"))

# Soft ink-wash circle in the upper right
$moonBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(24, 14, 14, 14))
$g.FillEllipse($moonBrush, 690, 120, 150, 150)

# Black diary card
$cardRect = New-Object System.Drawing.Rectangle(392, 312, 240, 400)
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$radius = 56
$d = $radius * 2
$path.AddArc($cardRect.X, $cardRect.Y, $d, $d, 180, 90)
$path.AddArc($cardRect.Right - $d, $cardRect.Y, $d, $d, 270, 90)
$path.AddArc($cardRect.Right - $d, $cardRect.Bottom - $d, $d, $d, 0, 90)
$path.AddArc($cardRect.X, $cardRect.Bottom - $d, $d, $d, 90, 90)
$path.CloseFigure()
$inkBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 14, 14, 14))
$g.FillPath($inkBrush, $path)

# White text lines inside the card
$lineBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 242, 240, 234))
$g.FillEllipse($lineBrush, 452, 392, 120, 22)
$g.FillEllipse($lineBrush, 452, 474, 120, 22)
$g.FillEllipse($lineBrush, 452, 556, 78, 22)

$g.Dispose()

$outDir = Join-Path $PSScriptRoot "..\MonoDiary\Assets.xcassets\AppIcon.appiconset"
$outPath = Join-Path $outDir "AppIcon.png"
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Host "AppIcon generated at $outPath"
