#!/usr/bin/env bash
# dv_audit.sh — verify DV environment alignment across all RTL repos.
# Run from workspace root: bash dv_audit.sh  OR  make audit
set -euo pipefail

WORKSPACE="$(cd "$(dirname "$0")" && pwd)"
FAIL=0

# Canonical versions from dv_env.mk
OSS_CAD_SUITE_VERSION=$(grep -m1 'OSS_CAD_SUITE_VERSION' "$WORKSPACE/dv_env.mk" | grep -oP '(?<=\?= ).*')
COCOTB_PIP_SPEC=$(grep -m1 'COCOTB_PIP_SPEC' "$WORKSPACE/dv_env.mk" | grep -oP '(?<=\?= ).*')

warn() { echo "  [WARN]  $*"; FAIL=1; }
ok()   { echo "  [OK]    $*"; }

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

  # 4. OSS CAD Suite version pin (only repos that use SymbiYosys)
  if [[ ! " ${flags[*]} " =~ " no-sby " ]]; then
    local ci_to_check="$ci_file"
    if grep -qF "$OSS_CAD_SUITE_VERSION" "$ci_to_check" 2>/dev/null; then
      ok "OSS_CAD_SUITE_VERSION: $OSS_CAD_SUITE_VERSION"
    else
      local actual
      actual=$(grep -oP '(?<=OSS_CAD_SUITE_VERSION: ")[^"]+' "$ci_to_check" 2>/dev/null | head -1 || true)
      if [[ -n "$actual" ]]; then
        warn "OSS_CAD_SUITE_VERSION mismatch: found '$actual', want '$OSS_CAD_SUITE_VERSION'"
      else
        warn "OSS_CAD_SUITE_VERSION not pinned (want '$OSS_CAD_SUITE_VERSION')"
      fi
    fi
  fi
}

echo "DV environment audit — workspace: $WORKSPACE"
echo "Canonical versions: OSS CAD Suite=$OSS_CAD_SUITE_VERSION  cocotb=$COCOTB_PIP_SPEC"

check_repo "IP-axi-to-2apbs"            no-sby        # has cocotb; formal uses apt Yosys, not OSS CAD
check_repo "chi-to-bow-bridge"          no-sby        # has cocotb, no sby formal
check_repo "axi4_to_dfi_ddr"            no-sby        # has cocotb, Yosys (not sby CI pin)
check_repo "ucie-cxl-bridge"                          # has cocotb + sby
check_repo "IP-ucie-rdi-to-pcie-pipe"   no-cocotb no-sby no-ci-rename

echo ""
if [[ $FAIL -eq 0 ]]; then
  echo "[AUDIT] All checks passed."
  exit 0
else
  echo "[AUDIT] One or more checks FAILED — see warnings above."
  exit 1
fi
