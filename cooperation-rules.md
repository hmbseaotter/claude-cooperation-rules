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
Whenever a turn ends by asking the user to approve, choose, confirm, or provide anything — INCLUDING a
plain yes/no or a "shall I proceed?" — surface it as a separate, arrow-key-selectable AskUserQuestion,
never as a question buried in prose. There is NO "too trivial to surface" exception: if your message's
purpose is to get the user to decide, it goes through the tool.
- Enumerate options in DESCENDING ORDER OF RECOMMENDATION — the recommended choice is FIRST and tagged
  `(Recommended)`. With no meaningful recommendation, order most- to least-likely.
- Always leave room for a free-text amendment. The tool's ever-present "Other"/free-text choice is the
  user's way to add a clarification or qualifier on top of (or instead of) a listed option — the user
  uses this frequently; never phrase a question that forecloses it.
- Read and weigh the user's ENTIRE reply before acting on ANY part of it — even when it opens with
  "yes/no" or a chosen option; a selection followed by more text may qualify, redirect, or override
  what was picked. Evaluate the whole response first, then act.

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

## Auto-formatter hooks — surface before reflowing hand-crafted files
Some setups run an auto-formatter (e.g. Prettier) as a PostToolUse hook that reformats a file every time
it is edited through the tools. A formatter changes only whitespace / quoting / wrapping — never
behaviour — but on the first edit it **reflows the entire file**, which destroys deliberate layout in
hand-crafted or intentionally-compact HTML/CSS/JS (e.g. printable infographics) and creates large diff
churn.

**Rule (active, machine-agnostic):** before editing an `.html` / `.css` / `.js` file in a project where
such a hook is (or may be) enabled, surface it to the user *first* — as a selectable question that
explains the effect (whole-file reflow; harmless to behaviour; big churn on hand-crafted files) and
offers: keep as-is · exempt this file (`.prettierignore` or an inline `<!-- prettier-ignore -->`) ·
proceed once. Never let a formatter silently clobber intentional formatting.

*Hook specifics (here for completeness — the rule above is the active, portable part; the concrete hook
it guards against is not global, it lives in the owner's `cli_projects` workspace): that hook is
**opt-in per project** via a `.prettier-hook` marker file, announces every reformat with disable
instructions, and is documented in `cli_projects/CLAUDE.md`.*
