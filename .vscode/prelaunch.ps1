$ErrorActionPreference = "Stop"

$workspaceRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$flutterRoot = "C:\FlutterSDK"
$flutterBin = Join-Path $flutterRoot "bin\flutter.bat"

if (-not (Test-Path $flutterBin)) {
    Write-Error "Flutter SDK not found at $flutterRoot. Install or update Flutter there, then reload VS Code."
    exit 1
}

$env:FLUTTER_ROOT = $flutterRoot
$env:PATH = "$flutterRoot\bin;$env:PATH"

Stop-Process -Name church -Force -ErrorAction SilentlyContinue

Push-Location $workspaceRoot
try {
    & $flutterBin pub get
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
} finally {
    Pop-Location
}

Write-Host "Pre-launch completed with Flutter SDK: $flutterRoot" -ForegroundColor Green
