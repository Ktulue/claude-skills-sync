# claude-skills-sync

Bootstrap script for syncing global Claude Code skills across machines (Mac/WSL).

## What It Installs

| Skill | Purpose | Source |
|-------|---------|--------|
| **Impeccable** | Frontend design quality — 1 skill + 17 commands | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) |
| **Sentry find-bugs** | Bug & vulnerability detection with confidence scoring | [getsentry/skills](https://github.com/getsentry/skills) |
| **Sentry security-review** | Security methodology (not just a checklist) | [getsentry/skills](https://github.com/getsentry/skills) |
| **Sentry code-review** | Code review following engineering best practices | [getsentry/skills](https://github.com/getsentry/skills) |
| **Sentry gha-security-review** | GitHub Actions workflow security review | [getsentry/skills](https://github.com/getsentry/skills) |
| **OWASP Security** | OWASP Top 10:2025, ASVS 5.0, 20+ language quirks | [agamm/claude-code-owasp](https://github.com/agamm/claude-code-owasp) |

Custom Ktulue skills (PR Summary Generator, Narrator, DepthCheck, etc.) are stubbed out and ready to uncomment once the skills repo is set up.

## What It Checks For (Manual Install Required)

| Tool | Purpose | Why Manual |
|------|---------|------------|
| **SuperPowers** | Development workflow (brainstorm → plan → TDD → review) | Plugin with hooks and session-start bootstrap — must be installed from inside Claude Code |

SuperPowers ([obra/superpowers](https://github.com/obra/superpowers)) can't be installed via file copy because it relies on Claude Code's plugin system for hooks, agents, and automatic session injection. The script detects whether it's already installed and prints the exact commands to run if it's not:

```
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

## Prerequisites

- `git`
- `curl`
- `npx` (optional — falls back to manual git clone if unavailable)

## Usage

```bash
# Clone this repo
git clone https://github.com/Ktulue/claude-skills-sync.git
cd claude-skills-sync

# Make executable and run
chmod +x install-claude-skills.sh
./install-claude-skills.sh
```

Or run directly without cloning:

```bash
curl -sL https://raw.githubusercontent.com/Ktulue/claude-skills-sync/main/install-claude-skills.sh | bash
```

## Where Skills Get Installed

All skills install globally to `~/.claude/skills/` so they're available across every project in Claude Code. Commands install to `~/.claude/commands/`.

## Updating

Re-run the script. It overwrites existing files with the latest versions from each source repo.

## Works On

- macOS (native terminal)
- Windows (via WSL)
- Linux

## Workflow Context

This installer is part of a broader Claude Code stack:

- **SuperPowers** — Development workflow (brainstorm → plan → TDD → review) *(checked, manual install)*
- **Impeccable** — Design quality layer *(installed by this script)*
- **Sentry + OWASP** — Security layers *(installed by this script)*
- **Custom skills** — Domain-specific knowledge (Narrator, DepthCheck, etc.) *(stubbed, uncomment when ready)*

## License

MIT