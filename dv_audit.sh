#!/usr/bin/env bash
# dv_audit.sh — verify DV environment alignment across all RTL repos.
# Run from workspace root: bash dv_audit.sh  OR  make audit
set -euo pipefail

WORKSPACE="$(cd "$(dirname "$0")" && pwd)"
FAIL=0

# Canonical versions from dv_env.mk
COCOTB_PIP_SPEC=$(grep -m1 'COCOTB_PIP_SPEC' "$WORKSPACE/dv_env.mk" | grep -oP '(?<=\?= ).*')

warn() { echo "  [WARN]  $*"; FAIL=1; }
ok()   { echo "  [OK]    $*"; }
info() { echo "  [INFO]  $*"; }   # advisory; never sets FAIL

check_repo() {
  local repo="$1"; shift
  local flags=("$@")   # options: no-cocotb no-sby no-ci-rename
  local dir="$WORKSPACE/$repo"

  echo ""
  echo "=== $repo ==="

  # 1. Standard Makefile targets
  local mk="$dir/Makefile"
  if [[ ! -f "$mk" ]]; then
    warn "Makefile missing"
  else
    for tgt in lint sim regress coverage formal ci clean; do
      if grep -qE "(^|[[:space:]])${tgt}[[:space:]]*(:|##)" "$mk"; then
        ok "make $tgt"
      else
        warn "make $tgt not found in Makefile"
      fi
    done
  fi

  # 2. CI file exists and is named ci.yml
  local ci_file="$dir/.github/workflows/ci.yml"
  if [[ " ${flags[*]} " =~ " no-ci-rename " ]]; then
    # Still on verilator.yml — flag it
    if [[ -f "$dir/.github/workflows/verilator.yml" && ! -f "$ci_file" ]]; then
      warn "CI file is verilator.yml — rename to ci.yml (TODO in DV_STANDARDS.md)"
    elif [[ -f "$ci_file" ]]; then
      ok "CI file: ci.yml"
    else
      warn "No CI file found"
    fi
  else
    if [[ -f "$ci_file" ]]; then
      ok "CI file: ci.yml"
    else
      warn "CI file missing or not named ci.yml"
    fi
  fi

  # 3. cocotb version pin
  if [[ ! " ${flags[*]} " =~ " no-cocotb " ]]; then
    local ci_to_check="$ci_file"
    [[ -f "$dir/.github/workflows/verilator.yml" && ! -f "$ci_file" ]] && \
      ci_to_check="$dir/.github/workflows/verilator.yml"
    if grep -qF "$COCOTB_PIP_SPEC" "$ci_to_check" 2>/dev/null; then
      ok "cocotb pin: $COCOTB_PIP_SPEC"
    else
      local actual
      actual=$(grep -oP "cocotb[=><!\s]*[0-9][^\s'\"]*" "$ci_to_check" 2>/dev/null | head -1 || true)
      if [[ -n "$actual" ]]; then
        warn "cocotb pin mismatch: found '$actual', want '$COCOTB_PIP_SPEC'"
      else
        warn "cocotb not pinned (want '$COCOTB_PIP_SPEC')"
      fi
    fi
  fi
}


# Standard make targets (DV_STANDARDS.md). Read from make's own rule database so
# aliases and includes are seen as make sees them; a directory that merely shares
# a target's name (e.g. formal/) does NOT count as the target.
STD_TARGETS="help lint sim regress coverage formal ci stress clean"
# Recommended-but-optional targets (toolchain audit, DV_STANDARDS.md "Toolchain
# standard"). Missing ones are reported [INFO], never a WARN — they don't gate.
OPT_TARGETS="tools tools-check"
# Repo directory names as they appear in this workspace (same list as the root Makefile).
RTL_REPOS=$(sed -n '/^RTL_REPOS :=/,/^$/p' "$WORKSPACE/Makefile" | sed 's/^RTL_REPOS ://; s/^=//; s/\\$//' | tr -s ' \n' ' ')

check_targets() {
  local repo="$1" dir="$WORKSPACE/$1"
  echo ""
  echo "=== $repo (make targets) ==="
  if [[ ! -d "$dir" ]]; then echo "  [SKIP]  not checked out"; return; fi
  if [[ ! -f "$dir/Makefile" ]]; then warn "Makefile missing"; return; fi
  local db tgt
  db=$(make -C "$dir" -qpRr 2>/dev/null </dev/null || true)
  for tgt in $STD_TARGETS; do
    if grep -qE "^${tgt}:" <<<"$db"; then ok "make $tgt"; else warn "make $tgt not defined"; fi
  done
  for tgt in $OPT_TARGETS; do
    if grep -qE "^${tgt}:" <<<"$db"; then ok "make $tgt"; else info "make $tgt not defined (recommended: toolchain audit)"; fi
  done
  # Bare 'make' must do exactly what 'make help' does.
  if [[ "$(make -C "$dir" -n 2>&1 </dev/null)" == "$(make -C "$dir" -n help 2>&1 </dev/null)" ]]; then
    ok "default goal = help"
  else
    warn "default goal is not help (bare 'make' should print the target list)"
  fi
}

echo "DV environment audit — workspace: $WORKSPACE"
echo "Canonical versions: cocotb=$COCOTB_PIP_SPEC"

check_repo "IP-axi-to-2apbs"            no-sby        # has cocotb; formal uses apt Yosys
check_repo "chi-to-bow-bridge"          no-sby        # has cocotb, no sby formal
check_repo "axi4_to_dfi_ddr"            no-sby        # has cocotb, Yosys (not sby CI pin)
check_repo "ucie-cxl-bridge"                          # has cocotb + sby
check_repo "IP-ucie-rdi-to-pcie-pipe"   no-cocotb no-sby no-ci-rename

for r in $RTL_REPOS; do check_targets "$r"; done

echo ""
if [[ $FAIL -eq 0 ]]; then
  echo "[AUDIT] All checks passed."
  exit 0
else
  echo "[AUDIT] One or more checks FAILED — see warnings above."
  exit 1
fi
