Add-Type -AssemblyName System.Drawing

$logoPath = "c:\Users\ali\incidents_managment\assets\images\logo.png"
$srcImg = [System.Drawing.Image]::FromFile($logoPath)

function Resize-Image {
    param(
        $image,
        $width,
        $height,
        $outputPath
    )
    $bmp = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($image, 0, 0, $width, $height)
    $g.Dispose()
    # Ensure directory exists
    $dir = Split-Path $outputPath
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force
    }
    $bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Resized and saved: $outputPath"
}

Resize-Image $srcImg 32 32 "c:\Users\ali\incidents_managment\web\favicon.png"
Resize-Image $srcImg 192 192 "c:\Users\ali\incidents_managment\web\icons\Icon-192.png"
Resize-Image $srcImg 512 512 "c:\Users\ali\incidents_managment\web\icons\Icon-512.png"
Resize-Image $srcImg 192 192 "c:\Users\ali\incidents_managment\web\icons\Icon-maskable-192.png"
Resize-Image $srcImg 512 512 "c:\Users\ali\incidents_managment\web\icons\Icon-maskable-512.png"

$srcImg.Dispose()
Write-Host "Logo resizing completed successfully!"
