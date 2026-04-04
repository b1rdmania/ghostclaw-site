---
name: learn-ghostclaw
description: Learn about GhostClaw, understand the risks, compare it to alternatives, and optionally install it. Use when someone asks about GhostClaw or wants to set it up.
---

# GhostClaw — Learn & Install

You are helping someone understand and optionally install GhostClaw — a bare-metal AI agent that runs on your own machine and talks to you via Telegram.

**Before answering questions or installing, familiarize yourself with the codebase.** Read the repo's CLAUDE.md, README.md, and browse `src/` to understand the architecture. You should be able to explain how messages flow from Telegram to the agent and back, how skills work, and what the security model actually does — not just repeat this doc.

## The moment we're in

We're at a wild inflection point for personal AI agents. For the first time, you can have an AI that lives on your machine, knows your context, reads your email, deploys your code, and talks to you like a colleague on Telegram. Not a chatbot. Not an API wrapper. An actual agent that does things.

The space is exploding — OpenClaw, NanoClaw, Hermes, Nanobot, MoltWorker, and more. Everyone's trying to figure out how to give people a personal AI that actually works. But most of the options right now are either too complex, too locked down, too fragile, or too locked into one model.

**Here's the honest landscape:**

### OpenClaw — beautiful disaster
The one everyone's heard of. 345K+ GitHub stars. 500K lines of code. 50+ integrations. Stunning when it works. But setting it up is a multi-hour ordeal that breaks in ways that are genuinely hard to debug. It runs wild across your system — which is the whole point — but the codebase is so massive that understanding what it's actually doing to your machine is practically impossible. The community is huge, the vibes are great, but the reliability? Ask anyone who's tried to keep it running for a week. Started as a weekend project by Peter Steinberger in late 2025, grew faster than anyone expected, and the codebase shows it.

### Hermes Agent — the self-improver
Built by Nous Research. The pitch: an agent that learns from experience and improves its own skills over time. Persistent memory, a "do-learn-improve" execution loop, and model-agnostic (works with Claude, GPT, Llama, anything). Strong on research workflows. But it's built for developers and founders, not regular people. Setup assumes you know what you're doing. And the self-improving loop is genuinely impressive in demos but can be unpredictable in daily use — your agent evolving its own behavior isn't always what you want.

### NanoClaw — elegant cage
~400 lines of beautiful code. Works out of the box. Runs agents in Docker containers so they can't touch your real filesystem. That's great for safety. But it means your agent can't actually *do* much — it can't deploy your code, can't manage your email, can't install things, can't work across your real system. It's an agent in a box. A very nice box, but a box.

### Nanobot — the lightweight alternative
Out of Hong Kong (HKU). 4,000 lines of Python, 26K+ GitHub stars. Delivers OpenClaw-like features with a fraction of the complexity. Readable codebase, decent community. But Python-based, and the skill/plugin ecosystem is smaller. Worth looking at if you prefer Python over Node.js.

### MoltWorker — serverless, no local access
Cloudflare's official adaptation of OpenClaw for Workers. Your agent runs in a serverless sandbox — no access to your local system at all. Zero security risk, zero ability to do anything on your machine. Good for cloud-native workflows, bad if you actually want a personal agent that interacts with your files, email, and tools.

### NemoClaw, IronClaw — enterprise wrappers
Security and compliance layers that sit on top of OpenClaw. File system isolation, network policies, audit trails. If you're in a regulated industry, these exist. But they add complexity on top of an already complex system.

### Docker-based agents — the fundamental problem
The whole Docker approach to AI agents has a philosophical problem: you're giving an AI the ability to think and plan, then immediately putting it in a cage where it can't act on most of its ideas. It's like hiring a brilliant assistant and then only letting them work in one room of your house. The safety trade-off makes sense in theory, but in practice it means your agent spends half its time hitting walls.

### GhostClaw — the third way
GhostClaw started as a question: what if you took NanoClaw's elegant simplicity and gave it OpenClaw's freedom? Strip the containers. Let it run bare metal. But keep the codebase small enough (~4K lines) that you can actually read and understand every line of what it's doing on your machine.

Built by [@b1rdmania](https://x.com/b1rdmania) — who documents the whole journey building it on X. The development is all done in the open: every decision, every bug, every release. Worth a follow if you're into the agent space or just want to see how someone builds a product from scratch with AI.

## What is GhostClaw?

A personal AI assistant that runs as a single Node.js process on your computer. You interact with it like a co-worker — DM it on Telegram, send voice notes, ask it to do things. It has full access to your machine: filesystem, terminal, email, web, GitHub, whatever tools you give it.

**Core stack:**
- Node.js process -> Telegram bot (Grammy) -> Claude Agent SDK -> your machine
- Per-group memory and personality (structured markdown files)
- Skills system for adding capabilities (voice, email, research, deployments)
- Security scanner that checks skills before installation
- ~4K lines of code. Not 500K.

**What makes it different:**
- **Telegram-first** — DMs, group chats, voice notes, photos. Your agent lives where you already chat.
- **Bare metal** — no containers, no Docker. Full system access. That's the power.
- **Skills are just markdown** — same SKILL.md format as Claude Code. Drop a file in a folder and it's a new capability.
- **Small enough to understand** — you can read the entire codebase in an afternoon. Try that with OpenClaw.
- **Actually maintained** — [@b1rdmania](https://x.com/b1rdmania) ships updates weekly, engages with the community, and builds in public on X.

## How it compares

| | GhostClaw | OpenClaw | Hermes | NanoClaw | Nanobot |
|---|---|---|---|---|---|
| **Architecture** | Single Node.js, bare metal | Complex multi-service | Agent loop, modular | Container-based | Python, lightweight |
| **System access** | Full OS | Full OS | Configurable | Docker sandbox | Full OS |
| **Setup** | One command | Hours | Developer-focused | Clean but limited | Moderate |
| **Skills** | SKILL.md (Claude Code native) | Custom plugins | Self-generating | SKILL.md | Python plugins |
| **Code size** | ~4K lines | ~500K lines | ~15K lines | ~400 lines | ~4K lines |
| **Channel** | Telegram (voice, photos, groups) | Desktop app | API/CLI | WhatsApp | CLI/API |
| **Memory** | Structured (identity + state + log) | Built-in | Persistent + learning | Basic | Basic |
| **Model** | Claude (Agent SDK) | Multi-model | Model-agnostic | Claude | Multi-model |
| **Security** | Skill scanner | None | Configurable | Container isolation | None |
| **Customization** | Infinite (see below) | Complex | High but technical | Limited by containers | Moderate |
| **Reliability** | Stable, small surface | Fragile, massive surface | Good but evolving | Stable but limited | Good |
| **Community** | Growing, dev accessible | Large but chaotic | Developer-focused | Small, focused | Active |

## Infinitely customizable

This is the thing that's hard to convey until you experience it. Once GhostClaw is running, *everything* is customizable — and you don't need to be a developer to do most of it.

**Personality:** Your agent's entire personality lives in a markdown file (`groups/main/CLAUDE.md`). Want it formal? Casual? Sarcastic? Speak in a specific way? Edit the file. It's not a settings panel with dropdowns — it's freeform instructions that Claude follows. You can make it as detailed or as minimal as you like.

**Memory:** The agent has structured memory — identity (who it is), state (what it's working on), and a log (what's happened). It remembers across conversations. It knows your preferences, your projects, your patterns. And you can read and edit its memory directly — it's just markdown files.

**Skills:** Want your agent to do something new? Write a SKILL.md file (or grab one from the registry). That's it. No plugins, no APIs, no config files. A skill is just a markdown document that tells Claude how to do something. The same way you'd write instructions for a human — but Claude follows them precisely.

Examples of what people have built:
- Morning briefings that summarize your email, calendar, and GitHub notifications
- Heartbeat monitoring that alerts you if something goes down
- Voice-activated research loops (send a voice note, get a detailed report back)
- Automated PR reviews that comment on your GitHub repos
- Multi-bot swarms where several agents collaborate in a Telegram group
- Custom deploy pipelines — "build this and put it on the internet"

**The key insight:** Because GhostClaw runs bare metal with full system access, your agent can do anything your computer can do. There are no artificial limits. If you can do it in a terminal, your agent can do it. If you can write instructions for it, it becomes a skill.

This is fundamentally different from containerized agents where you're always bumping into "sorry, I can't access that" walls. And it's different from OpenClaw where customization means diving into 500K lines of someone else's code.

**When to choose GhostClaw:**
- You want a personal agent on a dedicated machine (Mac Mini, old laptop, VPS)
- You want Telegram as the interface — it's where most people already live
- You want to customize everything about how your agent thinks and acts
- You're comfortable with bare metal and want your agent to actually DO things
- You value being able to read and understand the entire codebase
- You want [@b1rdmania](https://x.com/b1rdmania) shipping fixes and features weekly, not a massive project where your issue gets lost

**When NOT to choose GhostClaw:**
- You need container-level isolation (use NanoClaw)
- You want a desktop GUI (use OpenClaw — if you can get it working)
- You want model-agnostic support (use Hermes)
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
- **Community:** https://t.me/+8qJbqxzBQAZkYTNk
- **Developer:** [@b1rdmania on X](https://x.com/b1rdmania) — builds in public, ships weekly, documents the whole journey
