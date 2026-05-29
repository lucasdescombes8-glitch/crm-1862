# Simple HTTP Server for CRM App
$port = 3741
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "CRM Server running at http://localhost:$port/" -ForegroundColor Green

while ($true) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $urlPath = [System.Uri]::UnescapeDataString($request.Url.LocalPath)
        if ($urlPath -eq '/') { $urlPath = '/index.html' }

        $filePath = Join-Path $PSScriptRoot $urlPath

        if (Test-Path $filePath -PathType Leaf) {
            $content = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentLength64 = $content.Length

            # Set content type based on file extension
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
            $contentTypes = @{
                '.html' = 'text/html'
                '.js'   = 'application/javascript'
                '.css'  = 'text/css'
                '.json' = 'application/json'
                '.png'  = 'image/png'
                '.jpg'  = 'image/jpeg'
                '.gif'  = 'image/gif'
                '.svg'  = 'image/svg+xml'
            }
            $response.ContentType = $contentTypes[$ext] -or 'application/octet-stream'

            $response.OutputStream.Write($content, 0, $content.Length)
        } else {
            $response.StatusCode = 404
            $response.ContentType = 'text/plain'
            $errorMsg = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $urlPath")
            $response.OutputStream.Write($errorMsg, 0, $errorMsg.Length)
        }

        $response.OutputStream.Close()
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
}
