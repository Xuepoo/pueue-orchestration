# pueue-orchestration

Agent Skill for using [Pueue](https://github.com/Nukesor/pueue) as the
execution backbone of multi-agent workflows: persistent cross-session task
queues, group-per-agent isolation, and auditable results.

Pueue tasks outlive the agent session that created them — logs, exit codes,
and state are retained by the daemon. This turns fragile agent conversations
into a durable pipeline: a commander enqueues work, workers claim it, and
every result is verifiable via `pueue log`.

Pairs naturally with context engines like
[CarryCtx](https://github.com/Xuepoo/carryctx) — carryctx decides *what*
agents share; pueue decides *when and where* commands run.

## Install

### One command, all agents ([skills CLI](https://github.com/vercel-labs/skills))

```sh
npx skills add Xuepoo/pueue-orchestration -g
# or target specific agents:
npx skills add Xuepoo/pueue-orchestration -g -a claude-code -a opencode -a codex -a gemini-cli
```

The skill lives at `skills/pueue-orchestration/` and ships `SKILL.md`, helper
scripts, and a systemd user unit for the daemon.

### Manual

```sh
git clone https://github.com/Xuepoo/pueue-orchestration
cp pueue-orchestration/skills/pueue-orchestration/SKILL.md ~/.claude/skills/pueue-orchestration/
```

### Daemon setup (recommended)

```sh
mkdir -p ~/.config/systemd/user
cp skills/pueue-orchestration/assets/pueued.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now pueued.service
pueue status    # verify connectivity
```

## What the skill covers

- Command reference: add / stash / enqueue / wait / follow / log (`--json`)
- Commander + worker doctrine: group-per-agent dispatch, atomic task claiming
- Concurrency control (`pueue parallel`) for parallel subagents
- Pitfalls: shell escaping, JSON status shape, `reset` dangers, daemon recovery

## Requirements

- `pueue` / `pueued` (Rust CLI: `cargo install pueue pueued`), or the packaged binary
- `jq` (for the helper scripts)
- systemd user session (for the bundled service unit)

## License

MIT
