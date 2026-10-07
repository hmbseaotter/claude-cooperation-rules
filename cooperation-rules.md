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

## Context — one session per phase, reading delegated
A session's context is a working set, not an archive. Measured over a month of sessions on
2026-10-06: two thirds of all tokens went to calls made above 500k tokens of context, auto-compaction
fired at a median of 938k and kept 15k, and one file was read 79 times in a single session because
each compaction had erased it. A large window does not make filling it free — every call re-reads all
of it, and judgment degrades long before the ceiling.
- **One session per task or phase.** A phase boundary ends the session: Claude writes the handover
  to disk — decisions, open questions, file paths, the next step — and recommends a fresh session
  started from it. The recommendation names the **model and effort level** the next phase should run
  on: state the current model, assess the phase's cognitive load (heavy = novel architecture,
  cross-cutting judgment, subtle correctness; light = mechanical glue, deterministic wiring),
  recommend a model and an effort level (low · medium · high · xhigh · max), and flag a mismatch in
  both directions — under-powered risks a poor build, over-powered burns budget for nothing. The live
  effort setting may not be readable, so recommend and ask for confirmation rather than claim to
  detect it; the choice is the user's and goes on the record through *Surfacing decisions*.
- **Compact by hand, early, with a focus — never by the ceiling.** Auto-compaction is not a plan: it
  fires at the limit and keeps a sliver. A quarter of the window (the status line shows it) is a
  review point, not a stop: Claude says what share of the context is still live — files and results
  the next steps need — and what is dead weight — superseded file versions, old tool output, settled
  questions. Mostly dead: propose `/compact <focus>` naming what to keep — decisions, open questions,
  file paths, the current step — or a handover and a fresh session, whichever the remaining work
  warrants. Mostly live: carry on and say so; a large working set is what the window is for. Either
  way, by about two thirds of the window a compaction or handover happens on purpose, so the ceiling
  never decides. `/clear` between unrelated tasks.
- **Delegate reading.** A question that needs more than two files read goes to a sub-agent — Explore
  to locate, general-purpose to judge — that returns the conclusion; only its final report enters the
  session. Pure reading runs on a cheaper model. The main thread never holds a document it needed only
  to answer one question, and never re-reads a file already read this session when a targeted search
  (`grep`, a line range) would answer.

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
- **Assume another session may share the working tree.** Before any command that acts on the whole
  tree — `git add --renormalize .`, `git add -u`, `git stash`, `git checkout .` — run `git status`
  and check for other running sessions. Changes you did not make belong to someone: leave them
  unstaged and untouched, and say so. A whole-tree command stages or discards them along with yours.
- **Fetch before committing to a repository that may have moved elsewhere** — pushed from another
  machine, another clone or another session. Committing on a stale base turns the push into a
  rejected non-fast-forward, and the commit message you had approved may no longer be true once it
  is rebased onto what arrived. Never force-push to get past it.
- **CI runs by default; only listed slow-CI repositories skip it for text-only pushes.** Every push
  runs CI unless the repository is named in the **slow-CI list** kept in the machine's global
  `CLAUDE.md`. For a listed repository, when *every* commit in a push changes only documentation
  prose — Markdown documents such as READMEs, specifications, decision records, registers and
  handovers — put `[skip ci]` in the head commit's message, shown verbatim for approval like any
  other message. It is **not** text-only if any commit touches code, tests, tooling, config or CI
  workflows, or project *data*, even where that data is prose: transcripts, findings or labels,
  judgments, rubrics, prompts, policies, logs, snapshots, generated views. One such commit anywhere in
  the push means no `[skip ci]`, because a skip on the head commit would silence CI for the code
  beneath it. Before a skipped push, run the project's fast document checks locally when it has any:
  prose is often under test, and a skipped CI is the only other thing that would have noticed. The
  reason for the rule: a slow repository's full CI run can take ten minutes to over an hour, which a
  non-load-bearing prose change does not warrant; where CI finishes in a minute or two, skipping saves
  nothing and can silence work a workflow does beyond testing — such as asking another repository to
  run a check. A repository whose CI becomes slow is added to the list, not skipped by judgment.
- **Never write the skip marker in a commit message except to use it.** It matches anywhere
  in the head commit's message, so a message that *describes* the convention — quoting it,
  or explaining why an earlier commit carried it — skips the build it was meant to run. This
  happened on 2026-09-24: the commit repairing a red `main` skipped CI by quoting the marker
  in a sentence about the commit that had used it, and the push reported success with no run
  behind it. The failure is silent, which is what makes it worth a rule — nothing reports a
  workflow that never started, and the history reads green with a hole in it. Refer to it as
  *the skip marker* in prose and reserve the literal string for the line that means it; if a
  message must quote it, dispatch the workflow by hand afterwards and say so. The same
  reasoning is D89's in the harness project: a document explaining a checker cannot contain
  the checker's own trigger.
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

## Public artifacts carry no private context
Nothing destined for a public repository or page may reference the private reason it exists — a job
search (résumé, application, target company, recruiter, interview prep), a client, an employer, a
negotiation — unless the user explicitly asks for it. That covers files, commit messages, specs and
decision records, tests, and generated names.
- **A rule or a test that keeps a secret out must not spell the secret.** A word list to scan for
  lives outside the repository, never in a tracked file; splitting a word across string literals
  hides it from a scanner, not from a reader.
  **When a document must show one of these shapes, write it with placeholders** —
  `<drive_letter>:\<home_dir>\<username>`, `/<home_dir>/<username>`, `\\<host>\<share>` — and make
  *every* element a placeholder, the home directory included. A literal one still matches inside an
  example, and correctly so: a categorical rule cannot carry an exception for the parts that look
  generic. Two files learned this on 2026-09-24, both written to document the scanner that caught
  them.
- **Scan the whole history, not only the current files, before anything becomes public** —
  publishing a repository publishes every commit. Prove first that the scan can match a known
  instance: a pattern that cannot match reads exactly like a clean result.
- When in doubt whether a detail is private context, ask.

## Line endings — LF everywhere, held by the repository and by the code
Three layers, because each one covers a gap the others cannot:
- **Every repository ships a `.gitattributes` with `* text=auto eol=lf`**, from its first commit or the
  moment one is noticed missing. A machine-wide attributes file only covers the machine it is on; it
  does not travel with a clone, and a Windows clone with `core.autocrlf=true` then checks every text file
  out as CRLF — which breaks anything that compares files byte for byte. If the repository checks
  what it tracks against an allowlist, add the file to that list in the same commit.
- **Code that writes text files names the line ending** — in Python, `newline="\n"` on `open` /
  `write_text`, alongside `encoding="utf-8"`. No git setting reaches a file a program writes at run
  time, and on Windows Python writes CRLF by default; where output is hashed or compared, hold it
  with a test that the writer asks for LF.
- **Check line endings with `git ls-files --eol`**, never by grepping for a carriage return: the
  `i/` column is what is committed, the `w/` column what is on disk, and a grep for `\r` is easy to
  write wrongly and then read as a finding.

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
