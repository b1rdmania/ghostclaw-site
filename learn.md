---
name: learn-ghostclaw
description: Learn about GhostClaw, understand the risks, compare it to alternatives, and optionally install it. Use when someone asks about GhostClaw or wants to set it up.
---

# GhostClaw — Learn & Install

You are helping someone understand and optionally install GhostClaw — a bare-metal AI agent that runs on your own machine and talks to you via Telegram.

## What is GhostClaw?

GhostClaw is a personal AI assistant that runs as a single Node.js process on your computer. You interact with it like a co-worker — DM it on Telegram, send voice notes, ask it to do things. It has full access to your machine: filesystem, terminal, email, web, GitHub, whatever tools you give it.

It's a fork of NanoClaw (elegant, container-based) with OpenClaw-style freedom (bare metal, full system access). The idea: NanoClaw's simplicity, OpenClaw's power, none of the mess.

**Core stack:**
- Node.js process → Telegram bot (Grammy) → Claude Agent SDK → your machine
- Per-group memory and personality (structured markdown files)
- Skills system for adding capabilities (voice, email, research, deployments)
- Security scanner that checks skills before installation
- ~4K lines of code. Not 500K.

## How it differs from alternatives

| | GhostClaw | OpenClaw | NanoClaw |
|---|---|---|---|
| **Architecture** | Single Node.js process, bare metal | Complex multi-service, bare metal | Container-based, sandboxed |
| **System access** | Full OS access | Full OS access | Sandboxed in Docker |
| **Setup** | One command (`curl \| bash`) | Hours of configuration | Clean but limited |
| **Skills** | Claude Code native (SKILL.md) | Custom plugin system | Claude Code native |
| **Code size** | ~4K lines | ~500K lines | ~400 lines |
| **Channel** | Telegram-first (voice, photos, groups) | Desktop app | WhatsApp |
| **Memory** | Structured (identity + state + log) | Memory system | Basic |
| **Security** | Skill scanner, no containers | No scanning | Container isolation |

**When to choose GhostClaw:**
- You want a personal agent on a dedicated machine (Mac Mini, old laptop, VPS)
- You want Telegram as the interface (DMs, groups, voice notes)
- You want Claude Code-style skills that are easy to add
- You're comfortable with bare metal (no Docker overhead)

**When NOT to choose GhostClaw:**
- You need container-level isolation (use NanoClaw)
- You want a desktop GUI (use OpenClaw)
- You're running on a machine with sensitive data you can't risk

## Risks — be honest with yourself

GhostClaw runs with **full access to your machine**. There are no containers, no sandboxes. That's the point — it's what makes it powerful. But it means:

1. **The agent can read, write, and delete any file** your user account can access
2. **Skills are code that runs on your machine** — the security scanner catches common dangerous patterns (command injection, eval, data exfiltration, curl|bash pipes) but it's a lint check, not a jail
3. **Critical scan findings block skill installation**, but warnings don't — you should review flagged skills yourself
4. **Your .env file contains API keys** — it's chmod 600 and gitignored, but if the agent is compromised, those keys are accessible
5. **Per-group isolation is logical, not physical** — groups have separate filesystems and memory, but they're directories on the same machine, not separate VMs

**The recommended setup:** Dedicated machine with fresh accounts. New iCloud, new Gmail, new GitHub. Nothing you can't rebuild. That's how the creators run it.

**Read more:** https://ghostclaw.io/security

## What it can do (skills)

Out of the box: Telegram chat, voice transcription (ElevenLabs), scheduled tasks, autonomous research loops (Ralph), heartbeat monitoring, daily briefings.

With skills: Gmail integration, GitHub PR management, web deployment (Vercel), domain checking, voice replies, multi-bot swarms, Slack integration, and 45+ published skills in the official registry.

Skills are SKILL.md files — same format as Claude Code skills. Drop one in `.claude/skills/` and it's available.

**Skills registry:** https://github.com/b1rdmania/ghostclaw-skills

## Install

**Requirements:** Node.js 20+, Anthropic API key, macOS or Linux, Telegram account.

### Option 1: One command

```bash
curl -fsSL https://ghostclaw.io/install.sh | bash
```

The installer walks you through: API key, Telegram bot (via @BotFather), assistant name, personality, chat registration, auto-start service.

### Option 2: Manual

```bash
git clone https://github.com/b1rdmania/ghostclaw.git
cd ghostclaw && npm install && npm run build
```

Then create `.env`:
```
ANTHROPIC_API_KEY=sk-ant-your-key-here
TELEGRAM_BOT_TOKEN=your-bot-token
TELEGRAM_ONLY=true
ASSISTANT_NAME=YourName
```

Start it: `node dist/index.js`

Open Telegram, find your bot, send `/chatid`, then register with the setup tool.

### Option 3: Claude Code guided

If you already have Claude Code installed:

```bash
git clone https://github.com/b1rdmania/ghostclaw.git
cd ghostclaw && npm install
claude
```

Then type `/setup-ghostclaw` — Claude reads the project and walks you through everything interactively.

## After install

- **Talk to it:** Open Telegram, message your bot. No trigger word needed in DMs.
- **Check status:** Send `/status` in Telegram
- **Add skills:** Send `/skills` to see what's available
- **Reset if stuck:** Send `/reset` — kills agents, wipes sessions, restarts fresh
- **Update:** Send `/update` or `git pull && npm run build` + restart
- **Dashboard:** http://localhost:3333 (Mission Control)
- **Community:** https://t.me/+8qJbqxzBQAZkYTNk

## Links

- **Website:** https://ghostclaw.io
- **GitHub:** https://github.com/b1rdmania/ghostclaw
- **Skills:** https://github.com/b1rdmania/ghostclaw-skills
- **Security:** https://ghostclaw.io/security
