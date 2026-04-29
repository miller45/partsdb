# start-dev.ps1  --  Start PartsDB backend + Angular frontend
#
# Usage:  .\start-dev.ps1
# Stop:   Ctrl+C  (kills both processes)

$ErrorActionPreference = 'Stop'

$ScriptDir   = $PSScriptRoot
$BackendDir  = Join-Path $ScriptDir 'webbackend'
$FrontendDir = Join-Path $ScriptDir 'angularapp'

# -- Colour helpers ------------------------------------------
function log  { param($msg) Write-Host "[start-dev] $msg" -ForegroundColor Cyan   }
function ok   { param($msg) Write-Host "[start-dev] $msg" -ForegroundColor Green  }
function warn { param($msg) Write-Host "[start-dev] $msg" -ForegroundColor Yellow }
function err  { param($msg) Write-Host "[start-dev] $msg" -ForegroundColor Red    }

# -- Resolve dotnet ------------------------------------------
$dotnetOk = $false
try {
    $sdks = & dotnet --list-sdks 2>$null
    if ($sdks) { $dotnetOk = $true }
} catch {}

if (-not $dotnetOk) {
    $localDotnet = Join-Path $env:USERPROFILE '.dotnet\dotnet.exe'
    if (Test-Path $localDotnet) {
        $env:DOTNET_ROOT = Join-Path $env:USERPROFILE '.dotnet'
        $env:PATH = "$env:DOTNET_ROOT;$env:DOTNET_ROOT\tools;$env:PATH"
        log "Using dotnet from `$env:USERPROFILE\.dotnet"
    } else {
        err "dotnet SDK not found. Install .NET SDK from https://aka.ms/dotnet-download"
        exit 1
    }
}

# -- Resolve Node / npx --------------------------------------
if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
    err "npx not found. Install Node.js from https://nodejs.org"
    exit 1
}

# -- Build backend -------------------------------------------
log "Building .NET backend..."
Push-Location $BackendDir
try {
    & dotnet build -c Debug --nologo -v quiet
    if ($LASTEXITCODE -ne 0) {
        err "dotnet build failed -- aborting."
        exit 1
    }
} finally {
    Pop-Location
}

# -- Start backend -------------------------------------------
log "Starting .NET backend  ->  http://localhost:5287"
$backendJob = Start-Job -ScriptBlock {
    param($dir)
    Set-Location $dir
    $env:ASPNETCORE_ENVIRONMENT = 'Development'
    $env:ASPNETCORE_URLS        = 'http://localhost:5287'
    & dotnet bin/Debug/net9.0/PartsDb.Api.dll 2>&1 | ForEach-Object { "[API] $_" }
} -ArgumentList $BackendDir

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
Write-Host "  Backend:  http://localhost:5287" -ForegroundColor Cyan
Write-Host "  Swagger:  http://localhost:5287/swagger" -ForegroundColor Cyan
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
