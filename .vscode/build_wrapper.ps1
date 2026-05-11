param(
    [Parameter(Mandatory=$true)]
    [string]$BuildCommand
)

$ErrorActionPreference = "Stop"

$flutterRoot = "C:\FlutterSDK"
$flutterBin = Join-Path $flutterRoot "bin\flutter.bat"

if (-not (Test-Path $flutterBin)) {
    Write-Error "Flutter SDK not found at $flutterRoot. Install or update Flutter there, then reload VS Code."
    exit 1
}

$env:FLUTTER_ROOT = $flutterRoot
$env:PATH = "$flutterRoot\bin;$env:PATH"

Write-Host "Executing: flutter $BuildCommand" -ForegroundColor Green
& $flutterBin @($BuildCommand -split " ")

exit $LASTEXITCODE
