# claude-cooperation-rules

A tiny, **public, self-contained, non-destructive** installer that loads a set of Claude Code
"cooperation rules" (working-style guardrails) onto any machine in under a minute. Built for the
case where you sit down at an unfamiliar machine, need your guardrails active fast, and don't want to
fight with logins or tokens.

Everything here is plain text — working preferences + two small git guard scripts. **Nothing is
secret**, so there is **no login, no token, no network fetch** at install time: the files ship in
this repo and the installer just copies them into place.

---

## ⚠️ The one step everyone forgets

**After installing, you MUST restart Claude Code.** Claude Code reads its rules (`CLAUDE.md` and the
imported `cooperation-rules.md`) **once, when a session starts**. If you install while a session is
open, the rules do nothing until you **quit and reopen** Claude Code.

---

## TL;DR (if you know your way around a shell)

```sh
git clone https://github.com/hmbseaotter/claude-cooperation-rules.git
sh claude-cooperation-rules/install.sh
# then RESTART Claude Code
```

---

## Full step-by-step (assumes nothing)

> **Where you run this, and where it lands — read this first:**
> - **Run the commands from any directory** (home, Downloads, a scratch/temp folder — *anywhere*). They
>   do **not** need to be run from inside `~/.claude` or any special "Claude" folder.
> - **The cloned / unzipped `claude-cooperation-rules` folder is just a temporary *source*.** Put it
>   wherever is convenient — do **not** put it inside `~/.claude` — and you can **delete it once the
>   install finishes**; nothing depends on keeping it.
> - **The rules always install to the same fixed location**, no matter which directory you ran the
>   command from: `~/.claude/cooperation-rules.md`, a one-line edit to `~/.claude/CLAUDE.md`, and the
>   git-hooks dir (the full list is in *What gets installed* below). `~/` = your home folder
>   (`C:\Users\<you>` on Windows, `/home/<you>` on Linux, `/Users/<you>` on macOS).

### Step 1 — Get the files onto the machine
Pick whichever you can run:

- **If `git` is installed (most common):**
  ```sh
  git clone https://github.com/hmbseaotter/claude-cooperation-rules.git
  ```
  This creates a folder `claude-cooperation-rules/` in your current directory.

- **If `git` is NOT installed**, download the ZIP instead:
  1. Open https://github.com/hmbseaotter/claude-cooperation-rules in a browser.
  2. Click the green **Code** button → **Download ZIP**.
  3. Unzip it. You now have a `claude-cooperation-rules-main/` folder.
  - (Or, if you have `curl` + `tar` — both ship on macOS, Linux, and Windows 10+:
    `curl -fsSL https://github.com/hmbseaotter/claude-cooperation-rules/archive/refs/heads/main.tar.gz | tar xz`)

### Step 2 — Open a shell to run the installer in
The installer is a POSIX shell script (`install.sh`). It needs a **POSIX shell**:

| OS | Use this | How to open it |
|----|----------|----------------|
| **macOS** | Terminal | Spotlight (⌘-Space) → type "Terminal" |
| **Linux** | your terminal | e.g. Konsole / GNOME Terminal |
| **Windows** | **Git Bash** | Start menu → type "Git Bash" (comes with Git for Windows) |
| **Any (if Claude Code is open)** | **Claude Code's shell** | just ask Claude Code to run the command, or run it from its terminal — its shell is POSIX (Git Bash on Windows) |

> **Windows note:** do **NOT** use `cmd.exe` or **PowerShell** — they cannot run `install.sh`
> directly (it's a POSIX script). Use **Git Bash** (or Claude Code's shell). If you only have
> PowerShell and Git Bash's `sh` is on PATH, you can do `sh install.sh`, but Git Bash is simpler.

### Step 3 — Run the installer
From the folder you got in Step 1 (adjust the path if you used the ZIP, e.g. `claude-cooperation-rules-main`):

```sh
sh claude-cooperation-rules/install.sh
```
It prints each thing it does. It will not ask for any login or token.

### Step 4 — RESTART Claude Code
Quit Claude Code completely and reopen it. **Only now are the rules active.** (See the warning above.)

### Step 5 — Verify (optional)
In the new Claude Code session, ask: *"Are the cooperation-rules.md rules loaded?"* — or check that
`~/.claude/cooperation-rules.md` exists and that `~/.claude/CLAUDE.md` contains a
`# >>> claude-cooperation-rules >>>` block.

---

## What gets installed

| # | Path | Action |
|---|------|--------|
| 1 | `~/.claude/cooperation-rules.md` | **written** (copied from this repo) |
| 2 | `~/.claude/CLAUDE.md` | a **marked block** is appended adding one line: `@cooperation-rules.md`. Created if absent; **never overwritten**. |
| 3 | `<hooksdir>/pre-push`, `<hooksdir>/pre-commit` | **written only if `git` is installed AND the hook is absent.** An existing hook is **left untouched**. |
| 4 | `git config --global core.hooksPath` | set **only if `git` is installed and it is currently unset.** An already-set value is **never repointed**. |

`<hooksdir>` = your existing `core.hooksPath` if set, otherwise `~/.git-hooks` (created).

### No `git`? Still works.
If `git` isn't installed, the installer **still installs the behavioral rules** (steps 1–2 — the
guardrails that shape how Claude Code works) and simply **skips the git hooks** (steps 3–4) with a
note. Install `git` and re-run later to add them.

### What it will NOT do
- Never deletes anything, never overwrites your `CLAUDE.md`, never replaces an existing hook, never
  repoints an already-set `core.hooksPath`, never sends data anywhere, never asks for credentials.
- The hooks are conservative: **pre-push** only blocks a push whose GitHub owner isn't your
  authenticated `gh` account (bypass: `git push --no-verify`); **pre-commit** only blocks a commit
  with unresolved "HARD" contradictions in repos that ship `tools/contradiction_qa.py`, is a no-op
  everywhere else, and is fail-open (bypass: `git commit --no-verify`).

> **Heads-up for unfamiliar / borrowed machines (the pre-push hook):** the **pre-push** guard calls
> `gh` (GitHub CLI). If `gh` is missing or can't verify you, it **fails safe by BLOCKING the push** —
> and by design it blocks any push to a repo you don't own (e.g. a repo someone else owns). So if a push
> gets blocked, either bypass that one push with `git push --no-verify`, or delete the hook:
> `rm ~/.git-hooks/pre-push`. (The **pre-commit** gate has no such dependency.)

---

## Uninstall (fully reversible)
```sh
rm -f ~/.claude/cooperation-rules.md
# then open ~/.claude/CLAUDE.md and delete the block between these two lines:
#   # >>> claude-cooperation-rules >>>
#   # <<< claude-cooperation-rules <<<
# remove the hooks ONLY if this installer created them:
rm -f ~/.git-hooks/pre-push ~/.git-hooks/pre-commit
# and, ONLY if this installer set it (i.e. it was unset before):
git config --global --unset core.hooksPath
```
Then restart Claude Code.

## Idempotent
Re-running is safe: the `CLAUDE.md` import is added once (guarded by the markers), and existing hooks
are never overwritten.
