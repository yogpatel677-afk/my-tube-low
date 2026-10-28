$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$port = 8080
$page = 'TubeFlow_All_In_One.html'
$mime = @{ '.html'='text/html; charset=utf-8'; '.js'='application/javascript'; '.css'='text/css'; '.json'='application/json'; '.png'='image/png'; '.jpg'='image/jpeg'; '.svg'='image/svg+xml'; '.mp4'='video/mp4'; '.webm'='video/webm' }
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
try { $listener.Start() } catch { Write-Host "Could not start on port $port. Close other copies of this window and try again."; Read-Host "Press Enter to close"; exit 1 }
Write-Host "TubeFlow is running at http://localhost:$port/$page"
Write-Host "This runs only on your computer. Close this window to stop."
Start-Process "http://localhost:$port/$page"
while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    try {
        $rel = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath).TrimStart('/')
        if ($rel -eq '') { $rel = $page }
        $path = [IO.Path]::GetFullPath((Join-Path $root $rel))
        if ($path.StartsWith($root) -and (Test-Path -LiteralPath $path -PathType Leaf)) {
            $bytes = [IO.File]::ReadAllBytes($path)
            $ext = [IO.Path]::GetExtension($path).ToLower()
            if ($mime.ContainsKey($ext)) { $ctx.Response.ContentType = $mime[$ext] } else { $ctx.Response.ContentType = 'application/octet-stream' }
            $ctx.Response.ContentLength64 = $bytes.Length
            $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else { $ctx.Response.StatusCode = 404 }
    } catch { $ctx.Response.StatusCode = 500 }
    $ctx.Response.Close()
}
