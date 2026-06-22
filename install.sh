#!/bin/sh
# ============================================================================
#  claude-cooperation-rules — installer
#
#  WHAT THIS DOES (read before running; full details in README.md):
#    Installs a small set of Claude Code "cooperation rules" + two git safety
#    hooks onto this machine, NON-DESTRUCTIVELY. It never overwrites your
#    existing CLAUDE.md or your existing git hooks.
#
#  WHAT IT TOUCHES (exhaustive):
#    1. writes  ~/.claude/cooperation-rules.md           (the rules text)
#    2. appends a marked block to ~/.claude/CLAUDE.md:    "@cooperation-rules.md"
#       (between  >>> claude-cooperation-rules >>>  markers; created if absent)
#    3. writes  <hooksdir>/pre-push, <hooksdir>/pre-commit  (ONLY if absent;
#       an existing hook of that name is left untouched and reported)
#    4. sets  git config --global core.hooksPath  ONLY if it is currently unset
#
#  IT DOES NOT: delete anything, overwrite your CLAUDE.md, replace existing
#    hooks, repoint an already-set core.hooksPath, or send your data anywhere.
#
#  UNINSTALL: see README.md "Uninstall" (delete one file, remove one marked
#    block, delete two hook files) — one command, fully reversible.
#
#  SOURCE OF CONTENT: a PRIVATE GitHub repo (default: hmbseaotter/configs-c).
#    Requires GitHub CLI 'gh' authenticated as the repo owner, OR a read-only
#    GH_TOKEN for that repo. Override the repo with COOP_CONFIG_REPO=owner/name.
# ============================================================================
set -eu

CONFIG_REPO="${COOP_CONFIG_REPO:-hmbseaotter/configs-c}"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
RULES_DST="$CLAUDE_DIR/cooperation-rules.md"
CLAUDEMD="$CLAUDE_DIR/CLAUDE.md"
BEGIN="# >>> claude-cooperation-rules >>>"
END="# <<< claude-cooperation-rules <<<"
say() { printf '%s\n' "$*"; }
fetch() { gh api "repos/$CONFIG_REPO/contents/$1" --jq '.content' | base64 -d; }

# --- preflight: gh + auth (content is private) ---
command -v gh >/dev/null 2>&1 || { say "ERROR: GitHub CLI 'gh' is required. Install it and re-run."; exit 1; }
if ! gh auth status >/dev/null 2>&1 && [ -z "${GH_TOKEN:-}" ]; then
  say "Not authenticated to GitHub, and the rule content is in the PRIVATE repo $CONFIG_REPO."
  say "Do ONE of these, then re-run:"
  say "  (a) gh auth login          # logs your GitHub into this machine; 'gh auth logout' when done"
  say "  (b) GH_TOKEN=<read-only fine-grained PAT for $CONFIG_REPO> sh install.sh"
  exit 1
fi
mkdir -p "$CLAUDE_DIR"

# --- 1. rules text ---
say "Fetching cooperation-rules.md from $CONFIG_REPO ..."
fetch ".claude/cooperation-rules.md" > "$RULES_DST"
say "  wrote $RULES_DST"

# --- 2. import line in ~/.claude/CLAUDE.md (idempotent via markers; never overwrites) ---
[ -f "$CLAUDEMD" ] || : > "$CLAUDEMD"
if grep -qF "$BEGIN" "$CLAUDEMD" 2>/dev/null; then
  say "  import block already present in $CLAUDEMD (unchanged)"
else
  { printf '\n%s\n@cooperation-rules.md\n%s\n' "$BEGIN" "$END"; } >> "$CLAUDEMD"
  say "  added @cooperation-rules.md import to $CLAUDEMD"
fi

# --- 3. hooks dir: use existing core.hooksPath, else default to ~/.git-hooks (set only if unset) ---
HOOKS_DIR="$(git config --global core.hooksPath 2>/dev/null || true)"
if [ -z "$HOOKS_DIR" ]; then
  HOOKS_DIR="$HOME/.git-hooks"; mkdir -p "$HOOKS_DIR"
  git config --global core.hooksPath "$HOOKS_DIR"
  say "  set core.hooksPath -> $HOOKS_DIR (was unset)"
else
  say "  using existing core.hooksPath: $HOOKS_DIR"
fi

# --- 4. hooks: install ONLY if absent (never clobber an existing hook of the same name) ---
for h in pre-push pre-commit; do
  if [ -e "$HOOKS_DIR/$h" ]; then
    say "  ! $HOOKS_DIR/$h already exists — left untouched. Merge manually if you want this guard."
  else
    fetch ".git-hooks/$h" > "$HOOKS_DIR/$h"; chmod +x "$HOOKS_DIR/$h"
    say "  installed $HOOKS_DIR/$h"
  fi
done

say ""
say "Done — cooperation rules + git safety hooks are active. See README.md for uninstall."
