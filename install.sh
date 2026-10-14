#!/usr/bin/env bash
# Install or remove the miaa-bibtex skill set as portable skill directories.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"
MIRRORS=("${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}" "${GEMINI_SKILLS_DIR:-$HOME/.gemini/skills}")
[ -n "${CODEX_SKILLS_DIR:-}" ] && MIRRORS+=("$CODEX_SKILLS_DIR")

mode=install; force=0
for arg in "$@"; do
  case "$arg" in
    --install)   mode=install ;;
    --uninstall|--remove) mode=uninstall ;;
    --check)     mode=check ;;
    --force)     force=1 ;;
    -h|--help)   sed -n '2,7p' "$0"; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

names() { for d in "$SRC"/skills/*/; do basename "$d"; done; }

validate() {
  local fail=0 name fm_name fm_desc f
  for d in "$SRC"/skills/*/; do
    name="$(basename "$d")"; f="$d/SKILL.md"
    [ -f "$f" ] || { echo "MISSING SKILL.md: $name" >&2; fail=1; continue; }
    fm_name="$(awk -F': ' '/^name:/{print $2; exit}' "$f")"
    fm_desc="$(awk -F': ' '/^description:/{print $2; exit}' "$f")"
    [ "$fm_name" = "$name" ] || { echo "NAME MISMATCH: dir=$name name=$fm_name" >&2; fail=1; }
    [ -n "$fm_desc" ] || { echo "NO DESCRIPTION: $name" >&2; fail=1; }
    grep -q 'miaa-bibtex-core' "$f" || { echo "DOES NOT REFERENCE CORE: $name" >&2; fail=1; }
    grep -q '—' "$f" && { echo "EM DASH IN TEXT: $name" >&2; fail=1; }
  done
  return $fail
}

case "$mode" in
  check)
    validate && echo "OK: skill set is consistent" || { echo "FAILED"; exit 1; }
    ;;
  install)
    validate || { echo "refusing to install: validation failed" >&2; exit 1; }
    mkdir -p "$AGENTS"
    for d in "$SRC"/skills/*/; do
      name="$(basename "$d")"
      ln -sfn "$d" "$AGENTS/$name"
      for m in "${MIRRORS[@]}"; do mkdir -p "$m"; ln -sfn "$AGENTS/$name" "$m/$name"; done
      echo "installed $name"
    done
    echo "done. canonical root: $AGENTS"
    ;;
  uninstall)
    for m in "$AGENTS" "${MIRRORS[@]}"; do
      for name in $(names); do
        target="$m/$name"
        if [ -L "$target" ]; then rm -f "$target"; echo "removed $target"
        elif [ -d "$target" ]; then
          if [ "$force" = 1 ]; then rm -rf "$target"; echo "removed (forced) $target"
          else echo "kept (not a symlink, pass --force to remove): $target" >&2; fi
        fi
      done
    done
    echo "done. removed the miaa-bibtex skill links"
    ;;
esac
