#!/usr/bin/env bash
# GhostClaw Installer
# Usage: curl -fsSL https://ghostclaw.io/install.sh | bash
#    or: bash install.sh [install-dir]
set -euo pipefail

# ── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ── Helpers ─────────────────────────────────────────────────────────────────
info()  { printf "${GREEN}✓${RESET} %s\n" "$1"; }
warn()  { printf "${YELLOW}!${RESET} %s\n" "$1"; }
fail()  { printf "${RED}✗${RESET} %s\n" "$1"; exit 1; }
step()  { printf "\n${BOLD}[%s/%s]${RESET} %s\n" "$1" "$TOTAL_STEPS" "$2"; }
ask()   {
  local prompt="$1" default="${2:-}"
  if [ -n "$default" ]; then
    printf "${BLUE}?${RESET} %s ${DIM}(%s)${RESET}: " "$prompt" "$default"
  else
    printf "${BLUE}?${RESET} %s: " "$prompt"
  fi
  read -r REPLY
  [ -z "$REPLY" ] && REPLY="$default"
}
ask_secret() {
  printf "${BLUE}?${RESET} %s: " "$1"
  read -rs REPLY
  printf "\n"
}

INSTALL_STARTED=0
INSTALL_COMPLETE=0
INSTALL_DIR=""
TOTAL_STEPS=7
BOT_PID=""

cleanup() {
  # Kill temp bot if running
  if [ -n "$BOT_PID" ]; then
    kill "$BOT_PID" 2>/dev/null || true
    wait "$BOT_PID" 2>/dev/null || true
  fi
  # Remove partial install on failure
  if [ "$INSTALL_STARTED" -eq 1 ] && [ "$INSTALL_COMPLETE" -eq 0 ] && [ -n "$INSTALL_DIR" ]; then
    warn "Install failed — cleaning up $INSTALL_DIR"
    rm -rf "$INSTALL_DIR"
  fi
}
trap cleanup EXIT

# ── Banner ──────────────────────────────────────────────────────────────────
printf "\n"
printf "${BOLD}  GhostClaw Installer${RESET}\n"
printf "${DIM}  Personal AI assistant. Bare metal, Telegram-first.${RESET}\n"
printf "${DIM}  https://ghostclaw.io${RESET}\n"
printf "\n"

# ── Step 1: Prerequisites ──────────────────────────────────────────────────
step 1 "Checking prerequisites..."

# git
if ! command -v git &>/dev/null; then
  fail "git is not installed. Install it first: https://git-scm.com"
fi
info "git found"

# node
if ! command -v node &>/dev/null; then
  printf "\n"
  fail "Node.js is not installed. Install Node 20+:
    macOS:  brew install node
    Linux:  https://nodejs.org/en/download"
fi

NODE_VERSION=$(node --version | sed 's/^v//' | cut -d. -f1)
if [ "$NODE_VERSION" -lt 20 ]; then
  fail "Node.js $NODE_VERSION found, but 20+ is required. Upgrade: https://nodejs.org"
fi
info "Node.js v$(node --version | sed 's/^v//') found"

# npm
if ! command -v npm &>/dev/null; then
  fail "npm is not installed (should come with Node.js)"
fi
info "npm found"

# ── Step 2: Clone ──────────────────────────────────────────────────────────
step 2 "Setting up GhostClaw..."

INSTALL_DIR="${GHOSTCLAW_DIR:-${1:-$HOME/ghostclaw}}"

if [ -d "$INSTALL_DIR" ]; then
  if [ -d "$INSTALL_DIR/.git" ]; then
    REMOTE=$(git -C "$INSTALL_DIR" remote get-url origin 2>/dev/null || echo "")
    if echo "$REMOTE" | grep -q "ghostclaw"; then
      info "Existing GhostClaw install found at $INSTALL_DIR"
      ask "Update existing install? (y/n)" "y"
      if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
        git -C "$INSTALL_DIR" pull --rebase 2>/dev/null || git -C "$INSTALL_DIR" pull
        info "Updated to latest"
      fi
    else
      fail "$INSTALL_DIR exists but isn't a GhostClaw repo. Choose a different directory:
    GHOSTCLAW_DIR=~/my-ghostclaw bash install.sh"
    fi
  else
    fail "$INSTALL_DIR already exists. Choose a different directory:
    GHOSTCLAW_DIR=~/my-ghostclaw bash install.sh"
  fi
else
  INSTALL_STARTED=1
  git clone https://github.com/b1rdmania/ghostclaw.git "$INSTALL_DIR"
  info "Cloned to $INSTALL_DIR"
fi

cd "$INSTALL_DIR"

# ── Step 3: Install & Build ────────────────────────────────────────────────
step 3 "Installing dependencies..."

npm install --loglevel=warn 2>&1 | tail -3
info "Dependencies installed"

printf "    Building...\n"
npm run build 2>&1 | tail -1

if [ ! -f dist/index.js ]; then
  fail "Build failed — dist/index.js not found"
fi
info "Build complete"

# ── Step 4: Configuration ──────────────────────────────────────────────────
step 4 "Configuring GhostClaw..."

# Skip if .env already exists
if [ -f .env ] && grep -q "TELEGRAM_BOT_TOKEN" .env; then
  info "Existing .env found — skipping configuration"
  SKIP_CONFIG=1
else
  SKIP_CONFIG=0

  printf "\n"
  printf "  ${BOLD}Claude Authentication${RESET}\n"
  printf "  GhostClaw needs an Anthropic API key to think.\n"
  printf "\n"
  printf "    Get one at: ${BOLD}console.anthropic.com/settings/keys${RESET}\n"
  printf "    ${DIM}(Claude subscriptions no longer cover third-party tools)${RESET}\n"
  printf "\n"
  ask_secret "Anthropic API key (sk-ant-...)"
  API_KEY="$REPLY"
  if [ -z "$API_KEY" ]; then
    fail "API key cannot be empty"
  fi
  AUTH_LINE="ANTHROPIC_API_KEY=$API_KEY"

  printf "\n"
  printf "  ${BOLD}Telegram Bot${RESET}\n"
  printf "  Create a bot to give GhostClaw a Telegram presence:\n"
  printf "\n"
  printf "    1. Open Telegram, search for ${BOLD}@BotFather${RESET}\n"
  printf "    2. Send ${BOLD}/newbot${RESET}\n"
  printf "    3. Pick a name and username\n"
  printf "    4. Copy the token it gives you\n"
  printf "\n"
  ask_secret "Telegram bot token"
  TG_TOKEN="$REPLY"
  if [ -z "$TG_TOKEN" ]; then
    fail "Telegram bot token cannot be empty"
  fi

  printf "\n"
  ask "What should your assistant be called?" "GhostClaw"
  ASSISTANT_NAME="$REPLY"

  # Write .env
  cat > .env << ENVEOF
# Generated by GhostClaw installer — $(date +%Y-%m-%d)
$AUTH_LINE

ASSISTANT_NAME=$ASSISTANT_NAME
TELEGRAM_BOT_TOKEN=$TG_TOKEN
TELEGRAM_ONLY=true
ENVEOF

  chmod 600 .env
  info "Configuration saved to .env"
fi

# ── Step 5: Set up CLAUDE.md from templates ────────────────────────────────
step 5 "Setting up personality files..."

for dir in main global; do
  TEMPLATE="groups/$dir/CLAUDE.md.template"
  TARGET="groups/$dir/CLAUDE.md"
  if [ -f "$TEMPLATE" ] && [ ! -f "$TARGET" ]; then
    cp "$TEMPLATE" "$TARGET"
    # Replace default name with chosen name
    if [ "$SKIP_CONFIG" -eq 0 ] && [ -n "${ASSISTANT_NAME:-}" ] && [ "$ASSISTANT_NAME" != "Andy" ]; then
      sed -i.bak "s/^# Andy$/# $ASSISTANT_NAME/" "$TARGET" 2>/dev/null || \
        sed -i '' "s/^# Andy$/# $ASSISTANT_NAME/" "$TARGET"
      sed -i.bak "s/You are Andy/You are $ASSISTANT_NAME/g" "$TARGET" 2>/dev/null || \
        sed -i '' "s/You are Andy/You are $ASSISTANT_NAME/g" "$TARGET"
      rm -f "${TARGET}.bak"
    fi
    info "Created $TARGET"
  elif [ -f "$TARGET" ]; then
    info "$TARGET already exists — skipping"
  fi
done

# Create memory directory
mkdir -p groups/main/memory groups/main/logs
info "Group directories ready"

# ── Step 6: Register Telegram Chat ─────────────────────────────────────────
step 6 "Registering your Telegram chat..."

printf "\n"
printf "  Starting your bot temporarily so you can link your chat...\n"
printf "\n"

# Start bot in background
node dist/index.js &
BOT_PID=$!

# Give it a few seconds to connect
sleep 4

# Check it's running
if ! kill -0 "$BOT_PID" 2>/dev/null; then
  BOT_PID=""
  fail "Bot failed to start. Check logs/ghostclaw.log for details"
fi

printf "  ${GREEN}Bot is online!${RESET} Now:\n"
printf "\n"
printf "    1. Open Telegram\n"
printf "    2. Find your bot (search for its username)\n"
printf "    3. Send ${BOLD}/chatid${RESET}\n"
printf "    4. Copy the ID it replies with (looks like: ${DIM}tg:123456789${RESET})\n"
printf "\n"
ask "Paste your chat ID (tg:...)"
CHAT_ID="$REPLY"

# Stop temp bot
kill "$BOT_PID" 2>/dev/null || true
wait "$BOT_PID" 2>/dev/null || true
BOT_PID=""

if [ -z "$CHAT_ID" ]; then
  warn "No chat ID entered — you can register later with /setup-ghostclaw"
else
  # Ensure it has the tg: prefix
  if ! echo "$CHAT_ID" | grep -q "^tg:"; then
    CHAT_ID="tg:$CHAT_ID"
  fi

  TRIGGER="${ASSISTANT_NAME:-GhostClaw}"

  npx tsx setup/index.ts --step register \
    --jid "$CHAT_ID" \
    --name "Personal" \
    --trigger "@$TRIGGER" \
    --folder "main" \
    --no-trigger-required \
    --assistant-name "$TRIGGER" 2>/dev/null

  info "Chat registered: $CHAT_ID"
fi

# ── Step 7: Service Setup ──────────────────────────────────────────────────
step 7 "Setting up auto-start..."

printf "\n"
ask "Start GhostClaw automatically on boot? (y/n)" "y"

if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
  npx tsx setup/index.ts --step service 2>/dev/null
  info "Service installed and started"
else
  printf "\n"
  printf "  To start manually:\n"
  printf "    ${DIM}cd %s && node dist/index.js${RESET}\n" "$INSTALL_DIR"
  printf "\n"

  # Start it now anyway
  ask "Start GhostClaw now? (y/n)" "y"
  if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
    node dist/index.js &
    disown
    info "GhostClaw started (PID $!)"
  fi
fi

# ── Done ────────────────────────────────────────────────────────────────────
INSTALL_COMPLETE=1

printf "\n"
printf "  ${GREEN}${BOLD}GhostClaw is alive.${RESET}\n"
printf "\n"
printf "  ${BOLD}Location:${RESET}   %s\n" "$INSTALL_DIR"
printf "  ${BOLD}Dashboard:${RESET}  http://localhost:3333\n"
printf "  ${BOLD}Logs:${RESET}       %s/logs/ghostclaw.log\n" "$INSTALL_DIR"
printf "\n"
printf "  ${BOLD}Next steps:${RESET}\n"
printf "    Send a message to your bot on Telegram!\n"
printf "    Type ${BOLD}/skills${RESET} to see what it can do.\n"
printf "\n"
printf "  ${BOLD}Community:${RESET}  https://t.me/+8qJbqxzBQAZkYTNk\n"
printf "  ${BOLD}Docs:${RESET}       https://ghostclaw.io\n"
printf "\n"
