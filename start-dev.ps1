# start-dev.ps1  --  Start PartsDB backend + Angular frontend
#
# Usage:  .\start-dev.ps1
# Stop:   Ctrl+C  (kills both processes)

$ErrorActionPreference = 'Stop'

$ScriptDir   = $PSScriptRoot
$BackendDir  = Join-Path $ScriptDir 'djangobackend'
$FrontendDir = Join-Path $ScriptDir 'angularapp'

# -- Colour helpers ------------------------------------------
function log  { param($msg) Write-Host "[start-dev] $msg" -ForegroundColor Cyan   }
function ok   { param($msg) Write-Host "[start-dev] $msg" -ForegroundColor Green  }
function warn { param($msg) Write-Host "[start-dev] $msg" -ForegroundColor Yellow }
function err  { param($msg) Write-Host "[start-dev] $msg" -ForegroundColor Red    }

# -- Resolve python -----------------------------------------
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) { $pythonCmd = Get-Command python3 -ErrorAction SilentlyContinue }
if (-not $pythonCmd) {
    err "python (3.12+) not found. Install from https://www.python.org/downloads/"
    exit 1
}
$Python = $pythonCmd.Source

# -- Resolve Node / npx --------------------------------------
if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
    err "npx not found. Install Node.js from https://nodejs.org"
    exit 1
}

# -- Set up Python virtualenv --------------------------------
$VenvDir    = Join-Path $BackendDir '.venv'
$VenvPython = Join-Path $VenvDir 'Scripts\python.exe'
if (-not (Test-Path $VenvPython)) {
    log "Creating Python virtualenv at $VenvDir ..."
    & $Python -m venv $VenvDir
    & $VenvPython -m pip install --quiet --upgrade pip
    & $VenvPython -m pip install --quiet -e $BackendDir
}

# -- Migrate database ----------------------------------------
log "Applying migrations ..."
Push-Location $BackendDir
try {
    $env:DJANGO_SETTINGS_MODULE = 'partsdb.settings.dev'
    & $VenvPython manage.py migrate --no-input
    if ($LASTEXITCODE -ne 0) {
        err "migrate failed -- aborting."
        exit 1
    }
} finally {
    Pop-Location
}

# -- Start backend -------------------------------------------
log "Starting Django backend  ->  http://localhost:8000"
$backendJob = Start-Job -ScriptBlock {
    param($dir, $py)
    Set-Location $dir
    $env:DJANGO_SETTINGS_MODULE = 'partsdb.settings.dev'
    & $py manage.py runserver 0.0.0.0:8000 --noreload 2>&1 | ForEach-Object { "[API] $_" }
} -ArgumentList $BackendDir, $VenvPython

# Give the backend a moment to start
Start-Sleep -Seconds 2

# -- Start Angular dev server --------------------------------
log "Starting Angular frontend  ->  http://localhost:4200"
$frontendJob = Start-Job -ScriptBlock {
    param($dir)
    Set-Location $dir
    & npx @angular/cli@21 serve --open 2>&1 | ForEach-Object { "[WEB] $_" }
} -ArgumentList $FrontendDir

ok "Both services running. Press Ctrl+C to stop."
Write-Host ""
Write-Host "  Frontend: http://localhost:4200" -ForegroundColor Green
Write-Host "  Backend:  http://localhost:8000" -ForegroundColor Cyan
Write-Host "  API docs: http://localhost:8000/api/docs" -ForegroundColor Cyan
Write-Host ""

# -- Stream output and wait ----------------------------------
try {
    while ($true) {
        $backendJob, $frontendJob | ForEach-Object {
            $results = Receive-Job $_
            if ($results) { $results | ForEach-Object { Write-Host $_ } }
        }

        # If either job stopped unexpectedly, exit the loop
        if (($backendJob.State -ne 'Running') -or ($frontendJob.State -ne 'Running')) {
            break
        }

        Start-Sleep -Milliseconds 500
    }
} finally {
    warn "Shutting down..."
    $backendJob, $frontendJob | ForEach-Object {
        if ($_ -and $_.State -eq 'Running') {
            Stop-Job $_
        }
        Remove-Job $_ -Force -ErrorAction SilentlyContinue
    }
    ok "All processes stopped."
}
