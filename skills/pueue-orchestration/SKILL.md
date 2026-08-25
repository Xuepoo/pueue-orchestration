---
name: pueue-orchestration
description: Use when orchestrating long-running or parallel work across agent sessions with pueue — persistent task queues, group-per-agent dispatch, and cross-session task handoff. Also use to debug pueued connectivity (daemon not running, socket errors).
---

# Pueue Orchestration for Agents

Pueue (`pueue` client + `pueued` daemon) is a persistent command queue. Tasks
submitted by one agent session keep running after that session exits; logs,
exit codes, and state are retained in the daemon. This makes it the execution
backbone for multi-agent setups: a commander enqueues work, workers claim it,
and every result is auditable via `pueue log`.

## Prerequisites & connectivity

- Client: `pueue`, daemon: `pueued`. On this machine both live in
  `~/.local/share/cargo/bin/`.
- The daemon runs as a **user-level systemd service** (`pueued.service`,
  enabled). If any pueue command fails with
  `I/O error at path ".../pueue_<user>.socket" ... Did you start it?`, the
  daemon is down. Recover with:

```sh
systemctl --user status pueued        # diagnose
systemctl --user restart pueued       # restart
# fallback (no systemd): pueued -d
```

- Never run `pueued -d` while the systemd unit is active — two daemons fight
  over one socket.

## Core commands

| Task | Command |
|---|---|
| Enqueue | `pueue add -- 'cmd arg1 "quoted arg"'` |
| Enqueue + start now | `pueue add --immediate -- 'cmd'` |
| Create without starting | `pueue add --stashed -- 'cmd'` |
| Working directory | `pueue add -w /path/to/repo -- 'cmd'` |
| Named queue | `pueue group add <name>` then `add -g <name>` |
| Concurrency | `pueue parallel 4 -g <name>` |
| Claim stashed task | `pueue enqueue <id> && pueue start <id>` (usually implicit) |
| Wait (block) | `pueue wait <id> [--json]` |
| Follow output live | `pueue follow <id>` |
| Read result | `pueue log <id>` (full stdout/stderr + exit code) |
| Machine-readable state | `pueue status --json` / `pueue log --json <id>` |
| Send stdin to running task | `pueue send <id> 'y'` |
| Restart failed | `pueue restart <id...>` |
| Clean finished | `pueue clean` |

## Multi-agent doctrine: commander + worker

1. **One group per role/agent** keeps queues isolated:
   ```sh
   pueue group add agent-builder && pueue parallel 2 -g agent-builder
   ```
2. **Commander** creates tasks `-g <agent-group> --stashed` so nothing starts
   until a worker claims it.
3. **Worker** polls its group (`pueue status --json -g <name>`), claims via
   `pueue enqueue <id>`, monitors with `pueue wait <id>`, reports from
   `pueue log <id> --json`.
4. Pair with carryctx: carryctx owns shared context/state (SQLite, task
   tracking, worktrees); pueue owns *when and where commands execute*. Use
   `pueue add -w <worktree-path>` so each queued task runs inside an isolated
   git worktree created by carryctx.
5. Every task's output persists in the daemon — treat `pueue log` as the audit
   trail instead of piping long output through chat context.

## Pitfalls

- **Shell escaping**: everything after `--` goes through the system shell.
  Quote the whole command: `pueue add -- 'grep -rn "pattern" src/'`. Use
  `-e/--escape` only when you want NO shell interpretation.
- `pueue add` returns immediately with a task id — capture it if you plan to
  `wait` on it. With `--json` you get structured ids.
- `wait` blocks the calling process; prefer `pueue wait <id>` over polling
  loops, but never call it on a group you don't own.
- `pueue reset` kills ALL tasks and wipes state — never run it when other
  agents have live tasks. Prefer targeted `kill`/`clean`.
- Group removal moves its tasks back to `default`; don't remove groups that
  still hold queued work.
- Stashed tasks survive daemon restarts; plain queued tasks also do, but
  running processes are killed on daemon stop.

## Scripts

See `scripts/queue-init.sh` (create groups + set concurrency) and
`scripts/queue-claim.sh` (atomic worker claim flow). Both are safe to source
or execute directly; they require no dependencies beyond `jq`.
