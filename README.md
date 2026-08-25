# pueue-orchestration

Agent Skill for using [Pueue](https://github.com/Nukesor/pueue) as the
execution backbone of multi-agent workflows: persistent cross-session task
queues, group-per-agent isolation, and auditable results.

Pairs naturally with [CarryCtx](https://github.com/) (shared context/state +
git worktree isolation): carryctx decides *what* agents share, pueue decides
*when and where* commands run.

## Install (this machine)

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
