# Contributing

Thanks for your interest in **claude-cooperation-rules** — a tiny, public, **non-destructive**
installer that loads Claude Code working-style guardrails onto any machine in under a minute.
Contributions are welcome, but this repo has one overriding constraint.

## The prime directive: never break "safe on a borrowed machine"
The whole value of this tool is that you can run it on an **unfamiliar machine** with no risk. Any
change MUST preserve all of:
- **Non-destructive** — never deletes, never overwrites an existing `CLAUDE.md`, never replaces an
  existing git hook, never repoints an already-set `core.hooksPath`.
- **Idempotent** — a second run changes nothing (the `CLAUDE.md` import is marker-guarded).
- **No network, no login, no token** at install time — everything ships here as plain text.
- **POSIX `sh` only** — the installer runs under Git Bash on Windows and Terminal on macOS/Linux. No
  Bashisms, no PowerShell, no `python`.
- **Fail direction is deliberate** — the push-owner hook fails *closed*, the contradiction gate fails
  *open*. Keep that asymmetry.

If a change can't preserve all of the above, it's a different tool — open an issue to discuss first.

## Ways to contribute
- **Open an issue** for a bug or a proposed rule/installer change.
- **Send a PR** for fixes or new guardrails.

## Testing (use a throwaway home dir)
Never test against your real config. Point `HOME` (and `USERPROFILE` under Git Bash on Windows) at a
temp folder, then:
- run `sh install.sh` and confirm the rules land;
- confirm an existing `CLAUDE.md` is **preserved**, and a **second run is a no-op**;
- run the README's **Uninstall** steps and confirm the machine is restored cleanly.

## Conventions
- Rules live in `cooperation-rules.md` as plain, portable, machine-agnostic working preferences.
- `install.sh` prints each action it takes and asks for nothing.
- Update the README's *What gets installed* / *Uninstall* tables whenever install behavior changes.

## Pull requests
- Keep changes **focused**; clear commit messages (subject + a short "why").

## License
By contributing, you agree your contributions are released under this repository's
[MIT License](LICENSE).
