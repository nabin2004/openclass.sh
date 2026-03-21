#!/usr/bin/env bash
set -e

# ─────────────────────────────────────────────────────────
#  OpenClass.sh — Democratized, Personalized Education
#  https://openclass.sh | bash
#
#  Installs: Manimator MVP (full stack via Docker Compose)
#            Includes: Manimator + Dagestan
#
#  Built by Nabin — aspiring Research Engineer, Nepal
#  github.com/nabin2004
# ─────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

REPO="https://github.com/nabin2004/manimator-mvp"
INSTALL_DIR="$HOME/.openclass/manimator-mvp"

banner() {
  clear
  echo ""
  echo -e "${GREEN}${BOLD}"
  cat << 'EOF'
   ___                    ___  _
  / _ \ _ __  ___ _ __  / __|/ |__ _ ___  ___
 | (_) | '_ \/ -_) '  \| (__ | / _` (_-<(_-<
  \___/| .__/\___|_|_|_|\___|_|\__,_/__//__/
       |_|
EOF
  echo -e "${NC}"
  echo -e "  ${BOLD}${WHITE}OpenClass.sh${NC}  ${DIM}—  Democratized, Personalized Education${NC}"
  echo -e "  ${DIM}Built by Nabin · nabin2004 · Kathmandu, Nepal${NC}"
  echo -e "  ${DIM}──────────────────────────────────────────────${NC}"
  echo ""
}

log()  { echo -e "  ${CYAN}▸${NC} $1"; }
ok()   { echo -e "  ${GREEN}✓${NC}  $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC}  $1"; }
die()  { echo -e "\n  ${RED}✗  Error:${NC} $1\n"; exit 1; }
line() { echo -e "  ${DIM}────────────────────────────────────${NC}"; }

# ── 1. check deps ─────────────────────────────────────────
check_deps() {
  echo ""
  log "Checking dependencies..."
  echo ""

  command -v git  &>/dev/null || die "git is not installed. → https://git-scm.com"
  ok "git $(git --version | awk '{print $3}')"

  command -v docker &>/dev/null || die "Docker not found. → https://docs.docker.com/get-docker/"
  docker info &>/dev/null       || die "Docker daemon is not running. Please start Docker and retry."
  ok "docker $(docker --version | awk '{print $3}' | tr -d ',')"

  if docker compose version &>/dev/null 2>&1; then
    COMPOSE="docker compose"
  elif command -v docker-compose &>/dev/null; then
    COMPOSE="docker-compose"
  else
    die "Docker Compose not found. → https://docs.docker.com/compose/install/"
  fi
  ok "$COMPOSE $(${COMPOSE} version --short 2>/dev/null || echo '')"
}

# ── 2. clone / update ─────────────────────────────────────
clone_or_update() {
  echo ""
  line
  log "Setting up Manimator MVP..."
  echo ""

  mkdir -p "$(dirname "$INSTALL_DIR")"

  if [ -d "$INSTALL_DIR/.git" ]; then
    warn "Already installed at ${BOLD}$INSTALL_DIR${NC}"
    log "Pulling latest changes..."
    git -C "$INSTALL_DIR" pull --ff-only 2>/dev/null \
      || warn "Could not pull — you may be on a local branch. Continuing with existing version."
  else
    log "Cloning from $REPO ..."
    git clone --depth 1 "$REPO" "$INSTALL_DIR"
  fi

  ok "Repository ready"
}

# ── 3. env setup ──────────────────────────────────────────
setup_env() {
  echo ""
  line
  log "Configuring environment..."
  echo ""

  if [ -f "$INSTALL_DIR/.env.example" ] && [ ! -f "$INSTALL_DIR/.env" ]; then
    cp "$INSTALL_DIR/.env.example" "$INSTALL_DIR/.env"
    ok "Created .env from .env.example"
    warn "Edit ${BOLD}$INSTALL_DIR/.env${NC} to add your API keys before first use"

  elif [ -f "$INSTALL_DIR/.env" ]; then
    ok ".env already exists — skipping"

  else
    cat > "$INSTALL_DIR/.env" << 'ENVEOF'
# OpenClass.sh — environment configuration
# Fill in your values before running

OPENAI_API_KEY=
HF_TOKEN=

DAGESTAN_DB_PATH=/data/dagestan.db
MANIMATOR_OUTPUT_DIR=/outputs

NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_DAGESTAN_URL=http://localhost:8001
ENVEOF
    ok "Created placeholder .env"
    warn "Edit ${BOLD}$INSTALL_DIR/.env${NC} and add your API keys before launching"
  fi
}

# ── 4. docker compose up ──────────────────────────────────
launch() {
  echo ""
  line
  log "Pulling images and building containers..."
  log "This may take a few minutes on first run."
  echo ""

  cd "$INSTALL_DIR"
  $COMPOSE pull --quiet 2>/dev/null || true
  $COMPOSE up -d --build

  ok "All services started"
}

# ── 5. success ────────────────────────────────────────────
success() {
  echo ""
  echo -e "  ${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "  ${BOLD}${GREEN} OpenClass.sh is running!${NC}"
  echo -e "  ${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "  ${CYAN}OpenClass UI${NC}      →  ${BOLD}http://localhost:3000${NC}"
  echo -e "  ${CYAN}Manimator API${NC}     →  http://localhost:8000"
  echo -e "  ${CYAN}Dagestan API${NC}      →  http://localhost:8001"
  echo ""
  line
  echo ""
  echo -e "  ${DIM}Manage your stack:${NC}"
  echo -e "  ${DIM}  cd $INSTALL_DIR${NC}"
  echo -e "  ${DIM}  $COMPOSE logs -f          # stream logs${NC}"
  echo -e "  ${DIM}  $COMPOSE down             # stop everything${NC}"
  echo -e "  ${DIM}  $COMPOSE up -d --build    # rebuild & restart${NC}"
  echo ""
  echo -e "  ${DIM}GitHub     →  https://github.com/nabin2004${NC}"
  echo -e "  ${DIM}HuggingFace→  https://huggingface.co/nabin2004${NC}"
  echo ""
  echo -e "  ${DIM}Built by an underdog from Nepal. Learn freely.${NC}"
  echo ""
}

# ── main ──────────────────────────────────────────────────
banner
check_deps
clone_or_update
setup_env
launch
success