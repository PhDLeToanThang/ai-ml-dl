param(
    [string]$ProjectDir = (Split-Path -Parent $PSScriptRoot),
    [switch]$SkipVenv
)

$ErrorActionPreference = "Stop"
Write-Host "=== MCP Unified Integration Hub Setup ===" -ForegroundColor Cyan

# 1. Check Python
$pyVersion = python --version 2>&1
if ($pyVersion -match "Python 3\.1[2-9]|Python 3\.[2-9]\d") {
    Write-Host "[OK] $pyVersion" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Python 3.12+ required. Found: $pyVersion" -ForegroundColor Red
    exit 1
}

# 2. Check uv
if (Get-Command uv -ErrorAction SilentlyContinue) {
    Write-Host "[OK] uv found" -ForegroundColor Green
} else {
    Write-Host "[INFO] Installing uv..."
    powershell -ExecutionPolicy ByPass -c "Invoke-WebRequest -Uri https://astral.sh/uv/install.ps1 -UseBasicParsing | Invoke-Expression"
}

# 3. Create virtual environment
if (-not $SkipVenv) {
    $venvPath = Join-Path $ProjectDir ".venv"
    if (-not (Test-Path $venvPath)) {
        Write-Host "[...] Creating virtual environment..."
        uv venv $venvPath
    }
    Write-Host "[OK] Virtual environment ready" -ForegroundColor Green
}

# 4. Install dependencies
$requirements = Join-Path $ProjectDir "requirements.txt"
Write-Host "[...] Installing dependencies..."
uv pip install -r $requirements
Write-Host "[OK] Dependencies installed" -ForegroundColor Green

# 5. Copy .env if not exists
$envExample = Join-Path $ProjectDir ".env.example"
$envFile = Join-Path $ProjectDir ".env"
if (-not (Test-Path $envFile)) {
    Copy-Item $envExample $envFile
    Write-Host "[INFO] Created .env from .env.example - please edit with your settings" -ForegroundColor Yellow
}

# 6. Test import
Write-Host "[...] Testing imports..."
python -c "import mcp, httpx, yaml, pydantic, dotenv; print('[OK] All imports successful')" 2>&1

Write-Host "`n=== Setup Complete ===" -ForegroundColor Cyan
Write-Host "Run MCP server: python src\main.py" -ForegroundColor White
Write-Host "Run HTTP mode:  python src\main.py --transport http --port 8081" -ForegroundColor White
