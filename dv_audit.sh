#!/usr/bin/env bash
# dv_audit.sh — verify DV standards alignment across the RTL repos in this workspace.
# Run from workspace root: bash dv_audit.sh  OR  make audit
#
# Repos are AUTO-DISCOVERED: every immediate subdirectory that is a git repo with a
# root Makefile is audited (so a new bridge repo is covered the moment it is cloned
# here — no edit to this script needed). Canonical tool pins come from dv_env.mk.
set -uo pipefail

WORKSPACE="$(cd "$(dirname "$0")" && pwd)"
FAIL=0

# Canonical pins from dv_env.mk
# Value after `?=`, trimmed of surrounding whitespace (keeps internal spaces).
pinval() { grep -m1 "^$1" "$WORKSPACE/dv_env.mk" 2>/dev/null | grep -oP '(?<=\?=).*' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'; }
pin() { pinval "$1" | tr -d ' '; }
COCOTB_PIP_SPEC="$(pin COCOTB_PIP_SPEC)"
COCOTB_ACCEPTED="$(pinval COCOTB_ACCEPTED)"   # space-separated versions, e.g. "1.8.1 1.9.2"
ICARUS_MIN="$(pin ICARUS_MIN)"
VERILATOR_VERSION="$(pin VERILATOR_VERSION)"

# Standard root Makefile targets every RTL repo must expose (DV_STANDARDS.md).
STD_TARGETS=(lint sim regress coverage formal ci clean tools tools-check)

warn() { echo "  [WARN]  $*"; FAIL=1; }
ok()   { echo "  [OK]    $*"; }
info() { echo "  [INFO]  $*"; }

has_target() { grep -qE "(^|[[:space:]])${1}[[:space:]]*(:|##)" "$2"; }

# Find a pinned cocotb version anywhere a repo customarily declares it:
# CI workflows, Dockerfile (direct `cocotb==X` or an `ARG COCOTB_VERSION=X`), and
# requirements*.txt. Echoes the first version found, empty if none.
find_cocotb_version() {
  local dir="$1" v
  v=$(grep -rhoP "cocotb==\K[0-9][0-9.]*" \
        "$dir/.github/workflows/" "$dir"/Dockerfile* "$dir"/*/requirements*.txt \
        "$dir"/*/*/requirements*.txt 2>/dev/null | head -1)
  [[ -z "$v" ]] && v=$(grep -rhoP "ARG COCOTB_VERSION=\K[0-9][0-9.]*" "$dir"/Dockerfile* 2>/dev/null | head -1)
  echo "$v"
}

version_accepted() {
  local v="$1" a
  for a in $COCOTB_ACCEPTED; do [[ "$v" == "$a" ]] && return 0; done
  return 1
}

check_repo() {
  local dir="$1" repo
  repo="$(basename "$dir")"
  echo ""
  echo "=== $repo ==="

  # 1. Standard Makefile targets
  local mk="$dir/Makefile"
  if [[ ! -f "$mk" ]]; then
    warn "Makefile missing"
  else
    for tgt in "${STD_TARGETS[@]}"; do
      if has_target "$tgt" "$mk"; then ok "make $tgt"; else warn "make $tgt not found in Makefile"; fi
    done
  fi

  # 2. CI file exists and is named ci.yml
  local ci_file="$dir/.github/workflows/ci.yml"
  if [[ -f "$ci_file" ]]; then ok "CI file: ci.yml"; else warn "CI file missing or not named ci.yml"; fi

  # 3. cocotb pin — only if the repo actually uses cocotb
  if grep -rqiI 'cocotb' "$dir/.github/workflows/" "$dir"/Dockerfile* 2>/dev/null; then
    local v; v="$(find_cocotb_version "$dir")"
    if [[ -z "$v" ]]; then
      warn "cocotb referenced but no version pin found (want one of: $COCOTB_ACCEPTED)"
    elif version_accepted "$v"; then
      ok "cocotb pin: $v (accepted)"
    else
      warn "cocotb pin '$v' not in accepted set ($COCOTB_ACCEPTED) — update dv_env.mk or the repo"
    fi
  fi

  # 4. CLAUDE.md present (the auto-loaded working-conventions layer)
  if [[ -f "$dir/CLAUDE.md" ]]; then ok "CLAUDE.md present"; else warn "CLAUDE.md missing"; fi

  # 5. ASSERTIONS.md present (DV_STANDARDS assertion-inventory standard)
  if [[ -f "$dir/ASSERTIONS.md" ]]; then ok "ASSERTIONS.md present"; else info "ASSERTIONS.md missing (DV_STANDARDS TODO)"; fi
}

echo "DV standards audit — workspace: $WORKSPACE"
echo "Canonical pins: cocotb=$COCOTB_PIP_SPEC  verilator=$VERILATOR_VERSION  icarus>=$ICARUS_MIN"

n=0
for d in "$WORKSPACE"/*/; do
  d="${d%/}"
  [[ -d "$d/.git" && -f "$d/Makefile" ]] || continue
  check_repo "$d"
  n=$((n+1))
done

echo ""
echo "Audited $n repo(s)."
if [[ $FAIL -eq 0 ]]; then
  echo "[AUDIT] All checks passed."
  exit 0
else
  echo "[AUDIT] One or more checks FAILED — see warnings above."
  exit 1
fi
