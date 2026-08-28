# Claude Code — Cooperation Rules (portable)

Working-style rules for how Claude Code should collaborate. Path-agnostic; safe on any machine.

## Verify before answering — never guess at checkable state
When a question turns on the actual state of something, check the real source of truth first — don't
rely on memory, assumption, or inference when the ground truth is cheaply verifiable (a recalled fact
can be stale, an inferred one wrong). "State" means both **persistent** (files, configs, git status,
whether a step was done, a setting's value) AND **live/runtime** (which processes are actually running,
what a background job is doing, current resource state — inspect the running system). If something
genuinely can't be verified, say so rather than presenting a guess as fact.

## Close every turn with the assumptions it rested on
End each substantive turn with a short **Assumptions** list — every judgment call, filled-in gap, and
unverified premise the answer rests on, one line each, phrased plainly ("assumed X, because Y") with
the highest-stakes one first. This is the safety net under *Verify before answering*: what could be
checked was checked, and what could not gets named here instead of slipping through. An assumption
caught in the turn that made it costs a sentence to correct; the same assumption caught three turns
later has already been built on. Omit the list entirely when the turn assumed nothing — a ledger that
always reads "none" trains the reader to skip it.

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

## Scope — do what was asked, propose the rest
Deliver the request itself: what was asked for, plus what is genuinely necessary to make it work. No
speculative abstraction, no extra features, no adjacent files "improved" along the way. Thoroughness
is not a license to widen the job, and wanting to be helpful is not authorization to act unrequested.
- **Clarify before answering at length.** When two readings of a request would produce materially
  different work, ask before building — a wrong comprehensive answer costs the user far more than a
  question does. Reason the problem through first; don't start producing to look responsive.
- **When in doubt, ask — don't assume.** The companion to *Verify before answering*: check what is
  checkable, ask about what is not, and log whatever remains in the turn's assumption list.
- **Suggest, don't annex.** Improvements, extensions, and refactors you spot are worth raising — raise
  them as a proposal after the requested work, and stop there.
- **Say so when the approach is sub-optimal.** If the user's chosen path has a materially better
  alternative, name it and the reason before proceeding; silently executing a plan you believe is worse
  is a failure, not deference. If the user reaffirms their path, take that as the decision and proceed.
- Ask through the mechanism in *Surfacing decisions* — a selectable question, never one buried in prose.

## Output
- Show raw terminal/tool output verbatim; never paraphrase or summarize unless explicitly asked.
- Never prefix example commands with `!` (a Claude Code input-box shortcut, not shell syntax).

## Writing clarity
- When text references multiple entities, name each explicitly — never reuse "this"/"it" for different
  referents in close proximity. Separate distinct ideas visually (numbered leads, dividers).
- **US spelling by default** — "behavior", "color", "organize", "analyze", not the British forms —
  across prose, code, comments, and commit messages. Two overrides only: an explicit request for
  another variety, or an explicit instruction not to use US spelling. When editing a document already
  written in another variety, keep that document internally consistent rather than mixing forms, and
  say which you followed.

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
- **Never commit a populated `.env`**: a staged file named exactly `.env` over 20 bytes blocks the
  commit. `.gitignore` is the primary control; this is the backstop for when it is absent, edited, or
  bypassed with `git add -f`. Templates (`.env.example`) are unaffected, and the guard fails *closed*.
  A secret reaches the remote at `git push`, long before anything is published deliberately — treat
  anything that escapes as compromised and rotate it. (A global `pre-commit` guard enforces this —
  installed by this bundle.)
- **Contradiction pre-commit gate** (llm-wiki repos): a global `pre-commit` hook blocks commits with
  unresolved HARD contradictions in any repo shipping `tools/contradiction_qa.py`; no-op elsewhere;
  fail-open; bypass with `git commit --no-verify`. (Installed by this bundle.)

## Repo hygiene
Gitignore tool-/editor-/OS-generated junk; never commit it. When you notice such an untracked artifact,
add it to `.gitignore` and stage selectively so it can't slip into a commit.

## Auto-formatter hooks — surface before reflowing hand-crafted files
Some setups run an auto-formatter (e.g. Prettier) as a PostToolUse hook that reformats a file every time
it is edited through the tools. A formatter changes only whitespace / quoting / wrapping — never
behavior — but on the first edit it **reflows the entire file**, which destroys deliberate layout in
hand-crafted or intentionally-compact HTML/CSS/JS (e.g. printable infographics) and creates large diff
churn.

**Rule (active, machine-agnostic):** before editing an `.html` / `.css` / `.js` file in a project where
such a hook is (or may be) enabled, surface it to the user *first* — as a selectable question that
explains the effect (whole-file reflow; harmless to behavior; big churn on hand-crafted files) and
offers: keep as-is · exempt this file (`.prettierignore` or an inline `<!-- prettier-ignore -->`) ·
proceed once. Never let a formatter silently clobber intentional formatting.

*Hook specifics (here for completeness — the rule above is the active, portable part; the concrete hook
it guards against is not global, it lives in the owner's `cli_projects` workspace): that hook is
**opt-in per project** via a `.prettier-hook` marker file, announces every reformat with disable
instructions, and is documented in `cli_projects/CLAUDE.md`.*
