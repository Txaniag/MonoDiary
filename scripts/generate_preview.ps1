Add-Type -AssemblyName System.Drawing

$w = 720; $h = 960
$bmp = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.Clear([System.Drawing.ColorTranslator]::FromHtml('#FAF8F4'))

$ink = [System.Drawing.ColorTranslator]::FromHtml('#1B1917')
$gray = [System.Drawing.ColorTranslator]::FromHtml('#6E6A63')
$lightGray = [System.Drawing.ColorTranslator]::FromHtml('#A8A39A')
$borderPen = New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml('#EAE6DE'), 2)
$g.DrawRectangle($borderPen, 1, 1, $w-3, $h-3)

$serif = New-Object System.Drawing.Font('SimSun', 16, [System.Drawing.FontStyle]::Regular)
$serifBold = New-Object System.Drawing.Font('SimSun', 40, [System.Drawing.FontStyle]::Bold)
$serifQuote = New-Object System.Drawing.Font('SimSun', 64, [System.Drawing.FontStyle]::Regular)
$serifSmall = New-Object System.Drawing.Font('SimSun', 13, [System.Drawing.FontStyle]::Regular)
$serifMark = New-Object System.Drawing.Font('SimSun', 12, [System.Drawing.FontStyle]::Bold)

$sb = New-Object System.Drawing.SolidBrush($ink)
$sgray = New-Object System.Drawing.SolidBrush($gray)
$slight = New-Object System.Drawing.SolidBrush($lightGray)
$sf = New-Object System.Drawing.StringFormat
$sf.Alignment = [System.Drawing.StringAlignment]::Center
$sf.LineAlignment = [System.Drawing.StringAlignment]::Center

$g.DrawString('11月7日 · 2026', $serifSmall, $sgray, 48, 46)
$g.DrawEllipse((New-Object System.Drawing.Pen($gray, 2)), 624, 44, 18, 18)

$g.DrawString([string][char]0x201C, $serifQuote, $slight, 42, 240)

$titleRect = New-Object System.Drawing.RectangleF(60, 360, ($w-120), 90)
$g.DrawString('秋天的第一场雨', $serifBold, $sb, $titleRect, $sf)

$excerptRect = New-Object System.Drawing.RectangleF(100, 500, ($w-200), 180)
$g.DrawString('雨落在窗台上，像时间轻轻走过。今天没有特别的事，只是忽然想记下这一刻。', $serif, $sgray, $excerptRect, $sf)

$linePen = New-Object System.Drawing.Pen($lightGray, 2)
$g.DrawLine($linePen, 250, 852, 290, 852)
$g.DrawString('墨记', $serifMark, $slight, 305, 840)
$g.DrawLine($linePen, 365, 852, 405, 852)

$g.Dispose()
$outDir = '..\build'
$outPath = Join-Path $outDir 'preview-card.png'
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Host 'Preview saved: ' $outPath

