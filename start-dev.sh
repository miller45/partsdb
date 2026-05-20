#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
# start-dev.sh  –  Start PartsDB backend + Angular frontend
#
# Usage:  ./start-dev.sh
# Stop:   Ctrl+C  (kills both processes)
# ─────────────────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/djangobackend"
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

# ── Resolve python ───────────────────────────────────────────────
PYTHON="${PYTHON:-python3}"
if ! command -v "$PYTHON" &>/dev/null; then
  err "python3 not found. Install Python 3.12+."
  exit 1
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
VENV_DIR="$BACKEND_DIR/.venv"
if [ ! -d "$VENV_DIR" ]; then
  log "Creating Python virtualenv at $VENV_DIR …"
  "$PYTHON" -m venv "$VENV_DIR"
  "$VENV_DIR/bin/pip" install --quiet --upgrade pip
  "$VENV_DIR/bin/pip" install --quiet -e "$BACKEND_DIR"
fi

log "Applying migrations …"
( cd "$BACKEND_DIR" && "$VENV_DIR/bin/python" manage.py migrate --no-input 2>&1 ) \
  || { err "migrate failed – aborting."; exit 1; }

log "Starting Django backend  →  http://localhost:8000"
(
  cd "$BACKEND_DIR"
  DJANGO_SETTINGS_MODULE=partsdb.settings.dev \
  "$VENV_DIR/bin/python" manage.py runserver 0.0.0.0:8000 --noreload 2>&1 \
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
echo -e "  ${CYAN}Backend:${RESET}  http://localhost:8000"
echo -e "  ${CYAN}API docs:${RESET} http://localhost:8000/api/docs"
echo ""

# ── Wait for either process to exit ──────────────────────────────
wait -n 2>/dev/null || wait
cleanup

