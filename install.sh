#!/bin/sh
# ============================================================================
#  claude-cooperation-rules - self-contained installer
#
#  Copies the cooperation rules (+ optional git-safety hooks) shipped IN THIS
#  REPO into place, NON-DESTRUCTIVELY. No network, no GitHub login, no token.
#
#  WHAT IT TOUCHES (exhaustive):
#    1. writes  ~/.claude/cooperation-rules.md            (copied from this repo)
#    2. appends a marked block to ~/.claude/CLAUDE.md  ->  "@cooperation-rules.md"
#       (between markers; the file is created if absent; your file is NEVER
#        overwritten, only one block is appended once)
#    3. (only if git is installed) writes <hooksdir>/pre-push and pre-commit,
#       ONLY if absent - an existing hook of the same name is LEFT UNTOUCHED
#    4. (only if git is installed) sets core.hooksPath ONLY if it is unset
#
#  >>>>>>  AFTER RUNNING: RESTART Claude Code.  Rules load at STARTUP only,  <<<<<<
#  >>>>>>  so a session that was already open will NOT see them.            <<<<<<
#
#  Run it from a POSIX shell: macOS/Linux terminal, Windows GIT BASH (not cmd /
#  PowerShell), or Claude Code's own shell. Uninstall instructions: see README.md.
# ============================================================================
set -eu
SRC="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
RULES_DST="$CLAUDE_DIR/cooperation-rules.md"
CLAUDEMD="$CLAUDE_DIR/CLAUDE.md"
BEGIN="# >>> claude-cooperation-rules >>>"
END="# <<< claude-cooperation-rules <<<"
say() { printf '%s\n' "$*"; }

[ -f "$SRC/cooperation-rules.md" ] || { say "ERROR: run install.sh from inside the cloned repo."; exit 1; }
mkdir -p "$CLAUDE_DIR"

# 1. rules (no git, no network)
cp "$SRC/cooperation-rules.md" "$RULES_DST"
say "  rules : wrote $RULES_DST"

# 2. import line in ~/.claude/CLAUDE.md (idempotent via markers; never overwrites)
[ -f "$CLAUDEMD" ] || : > "$CLAUDEMD"
if grep -qF "$BEGIN" "$CLAUDEMD" 2>/dev/null; then
  say "  import: already present in $CLAUDEMD (unchanged)"
else
  { printf '\n%s\n@cooperation-rules.md\n%s\n' "$BEGIN" "$END"; } >> "$CLAUDEMD"
  say "  import: added @cooperation-rules.md to $CLAUDEMD"
fi

# 3. hooks (need git; skipped gracefully without it)
if command -v git >/dev/null 2>&1; then
  HOOKS_DIR="$(git config --global core.hooksPath 2>/dev/null || true)"
  if [ -z "$HOOKS_DIR" ]; then
    HOOKS_DIR="$HOME/.git-hooks"; mkdir -p "$HOOKS_DIR"
    git config --global core.hooksPath "$HOOKS_DIR"
    say "  hooks : set core.hooksPath -> $HOOKS_DIR (was unset)"
  else
    say "  hooks : using existing core.hooksPath: $HOOKS_DIR"
  fi
  for h in pre-push pre-commit; do
    if [ -e "$HOOKS_DIR/$h" ]; then
      say "  hooks : $HOOKS_DIR/$h exists - left untouched (merge manually if you want it)"
    else
      cp "$SRC/hooks/$h" "$HOOKS_DIR/$h"; chmod +x "$HOOKS_DIR/$h"
      say "  hooks : installed $HOOKS_DIR/$h"
    fi
  done
else
  say "  hooks : git not found -> SKIPPED git-safety hooks (behavioral rules still installed)."
  say "          Install git and re-run to add them."
fi

say ""
say "=================================================================="
say "  DONE.   >>>  NOW RESTART Claude Code  <<<   so it loads the rules."
say "  (CLAUDE.md is read only at startup; an already-open session"
say "   will NOT pick up the rules until you quit and reopen it.)"
say "=================================================================="
