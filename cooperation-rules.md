# Claude Code — Cooperation Rules (portable)

Working-style rules for how Claude Code should collaborate. Path-agnostic; safe on any machine.

## Verify before answering — never guess at checkable state
When a question turns on the actual state of something, check the real source of truth first — don't
rely on memory, assumption, or inference when the ground truth is cheaply verifiable (a recalled fact
can be stale, an inferred one wrong). "State" means both **persistent** (files, configs, git status,
whether a step was done, a setting's value) AND **live/runtime** (which processes are actually running,
what a background job is doing, current resource state — inspect the running system). If something
genuinely can't be verified, say so rather than presenting a guess as fact.

## Surfacing decisions — make every ask a standalone, selectable question
When a turn needs the user to approve, choose, or provide something, don't bury that ask in a status
paragraph. Surface it as a separate, arrow-key-selectable question (the AskUserQuestion tool) with
enumerated options; the always-present "Other"/free-text choice lets the user add a related comment.
Read and weigh the user's ENTIRE reply before acting — even when it opens with "yes/no"; a leading
"yes" followed by more text may qualify, redirect, or override it.

## Output
- Show raw terminal/tool output verbatim; never paraphrase or summarize unless explicitly asked.
- Never prefix example commands with `!` (a Claude Code input-box shortcut, not shell syntax).

## Writing clarity
When text references multiple entities, name each explicitly — never reuse "this"/"it" for different
referents in close proximity. Separate distinct ideas visually (numbered leads, dividers).

## Git safety
- **Commit-message approval:** before every commit (and the push after), draft the message, show it
  verbatim, and commit only after the user approves it. Use `git commit -F <file>` for messages with
  shell-significant characters, and verify HEAD advanced afterward.
- **Separate unrelated changes** into standalone commits — never bundle unrelated work; stage
  selectively (`git add <path>`, never `git add -A`).
- **Push-destination guardrail:** before any push, compare the remote's GitHub owner to the
  authenticated `gh` user. Match → push normally. Differ or unverifiable → do NOT push; warn it's not
  your repo and require an explicit one-time challenge-code confirmation before `git push --no-verify`.
  (A global `pre-push` hook enforces this independently — installed by this bundle.)
- **Contradiction pre-commit gate** (llm-wiki repos): a global `pre-commit` hook blocks commits with
  unresolved HARD contradictions in any repo shipping `tools/contradiction_qa.py`; no-op elsewhere;
  fail-open; bypass with `git commit --no-verify`. (Installed by this bundle.)

## Repo hygiene
Gitignore tool-/editor-/OS-generated junk; never commit it. When you notice such an untracked artifact,
add it to `.gitignore` and stage selectively so it can't slip into a commit.
