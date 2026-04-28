#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
# start-dev.sh  –  Start PartsDB backend + Angular frontend
#
# Usage:  ./start-dev.sh
# Stop:   Ctrl+C  (kills both processes)
# ─────────────────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/webbackend"
FRONTEND_DIR="$SCRIPT_DIR/angularapp"

# ── Colour helpers ────────────────────────────────────────────────
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

log()  { echo -e "${CYAN}[start-dev]${RESET} $*"; }
ok()   { echo -e "${GREEN}[start-dev]${RESET} $*"; }
warn() { echo -e "${YELLOW}[start-dev]${RESET} $*"; }
err()  { echo -e "${RED}[start-dev]${RESET} $*" >&2; }

# ── Resolve dotnet ────────────────────────────────────────────────
if ! command -v dotnet &>/dev/null; then
  if [ -x "$HOME/.dotnet/dotnet" ]; then
    export DOTNET_ROOT="$HOME/.dotnet"
    export PATH="$HOME/.dotnet:$HOME/.dotnet/tools:$PATH"
    log "Using dotnet from \$HOME/.dotnet"
  else
    err "dotnet not found. Install .NET SDK from https://aka.ms/dotnet-download"
    exit 1
  fi
fi

# ── Resolve Node / npx ───────────────────────────────────────────
if ! command -v npx &>/dev/null; then
  err "npx not found. Install Node.js from https://nodejs.org"
  exit 1
fi

# ── Track child PIDs for clean shutdown ──────────────────────────
BACKEND_PID=""
FRONTEND_PID=""

cleanup() {
  echo ""
  warn "Shutting down…"
  [ -n "$BACKEND_PID" ]  && kill "$BACKEND_PID"  2>/dev/null && log "Backend stopped  (PID $BACKEND_PID)"
  [ -n "$FRONTEND_PID" ] && kill "$FRONTEND_PID" 2>/dev/null && log "Frontend stopped (PID $FRONTEND_PID)"
  wait 2>/dev/null
  ok "All processes stopped."
}
trap cleanup INT TERM

# ── Start backend ────────────────────────────────────────────────
log "Building .NET backend…"
( cd "$BACKEND_DIR" && dotnet build -c Debug --nologo -v quiet 2>&1 ) \
  || { err "dotnet build failed – aborting."; exit 1; }

log "Starting .NET backend  →  http://localhost:5287"
# Run the compiled dll directly to avoid the inotify file-watcher limit
(
  cd "$BACKEND_DIR"
  ASPNETCORE_ENVIRONMENT=Development \
  ASPNETCORE_URLS="http://localhost:5287" \
  dotnet bin/Debug/net9.0/PartsDb.Api.dll 2>&1 \
    | sed "s/^/$(printf '\033[0;36m')[API]$(printf '\033[0m') /"
) &
BACKEND_PID=$!

# Give the backend a moment to start before the browser opens
sleep 2

# ── Start Angular dev server ─────────────────────────────────────
log "Starting Angular frontend  →  http://localhost:4200"
( cd "$FRONTEND_DIR" && npx @angular/cli@21 serve --open 2>&1 | sed "s/^/$(printf '\033[0;32m')[WEB]$(printf '\033[0m') /" ) &
FRONTEND_PID=$!

ok "Both services running. Press Ctrl+C to stop."
echo ""
echo -e "  ${GREEN}Frontend:${RESET} http://localhost:4200"
echo -e "  ${CYAN}Backend:${RESET}  http://localhost:5287"
echo -e "  ${CYAN}Swagger:${RESET}  http://localhost:5287/swagger"
echo ""

# ── Wait for either process to exit ──────────────────────────────
wait -n 2>/dev/null || wait
cleanup

