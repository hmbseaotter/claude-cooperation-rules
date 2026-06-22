# claude-cooperation-rules

A tiny, **non-destructive** installer that adds a set of Claude Code "cooperation rules" (working-style
preferences) and two optional git-safety hooks to a machine. Built so it can be run on *any* machine —
yours or someone else's — and so a cautious host can read exactly what it does **before** running it.

> **Nothing here is secret or sensitive.** These are working preferences (how Claude Code should
> verify facts, surface decisions, and handle git safely). The installer is public so you can inspect
> it first; the rule *text* itself is pulled at install time from a private repo you control.

## What gets installed

| # | Path | Action |
|---|------|--------|
| 1 | `~/.claude/cooperation-rules.md` | **written** (the rules text) |
| 2 | `~/.claude/CLAUDE.md` | a **marked block** is appended that adds one line: `@cooperation-rules.md`. Your existing CLAUDE.md is **never overwritten** — created only if absent. |
| 3 | `<hooksdir>/pre-push`, `<hooksdir>/pre-commit` | **written only if absent.** An existing hook of the same name is **left untouched** and reported. |
| 4 | `git config --global core.hooksPath` | set **only if currently unset**. An already-set hooksPath is **never repointed**. |

`<hooksdir>` = your existing `core.hooksPath` if set, otherwise `~/.git-hooks` (created).

### What it will NOT do
- It will not delete anything, overwrite your `CLAUDE.md`, replace an existing hook, repoint an
  already-configured `core.hooksPath`, or transmit any of your data anywhere.
- The two hooks are themselves conservative: **pre-push** only blocks a push whose GitHub owner isn't
  your authenticated `gh` account (bypass: `git push --no-verify`); **pre-commit** only blocks a commit
  with unresolved "HARD" contradictions in repos that ship `tools/contradiction_qa.py`, and is a no-op
  everywhere else and fail-open (bypass: `git commit --no-verify`).

## Requirements
- [GitHub CLI `gh`](https://cli.github.com/), authenticated as the owner of the private content repo,
  **or** a read-only fine-grained `GH_TOKEN` for that repo (the rule text lives in a private repo).
- POSIX shell + `git`.

## Install
```sh
# inspect first (recommended), then:
sh install.sh
# foreign machine without gh login? use a read-only token instead:
GH_TOKEN=<fine-grained PAT, read-only, that one repo> sh install.sh
```
Point it at a different private content repo with `COOP_CONFIG_REPO=owner/name sh install.sh`.

## Uninstall (fully reversible)
```sh
rm -f ~/.claude/cooperation-rules.md
# remove the block between the two "claude-cooperation-rules" markers in ~/.claude/CLAUDE.md
# (delete the hooks only if this installer created them):
rm -f "$(git config --global core.hooksPath)/pre-push" "$(git config --global core.hooksPath)/pre-commit"
# and, only if this installer set it: git config --global --unset core.hooksPath
```

## Idempotent
Re-running is safe: the CLAUDE.md import is added once (guarded by markers), and existing hooks are
never overwritten.
