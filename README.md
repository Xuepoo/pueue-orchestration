# pueue-orchestration

Agent Skill for using [Pueue](https://github.com/Nukesor/pueue) as the
execution backbone of multi-agent workflows: persistent cross-session task
queues, group-per-agent isolation, and auditable results.

Pairs naturally with [CarryCtx](https://github.com/) (shared context/state +
git worktree isolation): carryctx decides *what* agents share, pueue decides
*when and where* commands run.

## Install

### One command, all agents ([skills CLI](https://github.com/vercel-labs/skills))

```sh
npx skills add Xuepoo/pueue-orchestration -g
# or target specific agents:
npx skills add Xuepoo/pueue-orchestration -g -a claude-code -a opencode -a codex -a gemini-cli
```

The repo root `SKILL.md` is discovered automatically; scripts and assets ship with it.

### Manual

```sh
git clone https://github.com/Xuepoo/pueue-orchestration
cp pueue-orchestration/SKILL.md ~/.claude/skills/pueue-orchestration/   # repeat per agent
```

### Daemon (this machine)

```sh
systemctl --user daemon-reload
systemctl --user enable --now pueued.service   # assets/pueued.service copied to ~/.config/systemd/user/
pueue status                                   # verify connectivity
```

## Skill contents

- `SKILL.md` — trigger conditions, command reference, commander/worker doctrine, pitfalls
- `scripts/queue-init.sh` — create named groups with concurrency limits
- `scripts/queue-claim.sh` — worker claim flow: pick oldest stashed task, run, return JSON log
- `assets/pueued.service` — systemd user unit template

## Requirements

- `pueue` / `pueued` (Rust CLI, `cargo install pueue`)
- `jq` (for the scripts)
