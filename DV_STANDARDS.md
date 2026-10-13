# DV Standards — RTL Workspace

**Applies to:** every RTL/DV repo in the workspace (the `RTL_REPOS` list in the
root `Makefile`): `IP-axi-to-2apbs`, `IP-ucie-rdi-to-pcie-pipe`, `axi4_to_dfi_ddr`,
`chi-to-bow-bridge`, `ucie-cxl-bridge`, `tilelink_to_AXI4`, `cxl_lpddr5x_bridge`,
`chi-to-cxl-bridge`, `chi-to-ucie-bridge`, `ucie_rdi_to_pcie6_pipe7`, `si5_prep`,
`axi-on-ucie-to-mem`, `ucie2-pipe7-bridge`, `eth-dj-to-pcie-pipe-bridge`,
`eth-dj-pcie-pipe7_1-bridge`, `uvm_review`, `apb-to-mem-all-py`, `apb-to-mem-bazel`

---

## Standard Makefile targets

Every RTL repo must expose these root-level targets with consistent semantics.
Run `make audit` from the workspace root to check them (`dv_audit.sh` reads make's
rule database, so a directory that merely shares a name, e.g. `formal/`, does not count).
`make repos-<target>` from the workspace root runs one target in every repo.

| Target | What it runs | Must exit 0 |
|--------|-------------|-------------|
| `make` (no args) | Same as `make help` — the default goal never runs a gate | Always |
| `make help` | Print the target list | Always |
| `make lint` | Verilator `--lint-only -Wall` on all RTL modules | Always |
| `make sim` | Primary directed simulation (Icarus or Verilator C++) | Always |
| `make regress` | `lint` + `sim` (a repo may add more tiers) — **the fast CI gate** | Always |
| `make coverage` | Verilator `--coverage` simulation + `lcov` report | Yes (or print stub message and exit 0) |
| `make formal` | SymbiYosys BMC + cover on key modules | Yes (or print stub and exit 0) |
| `make ci` | `regress` + `coverage` + `formal` — comprehensive local run | Always |
| `make stress` | Stress / randomized simulation | Yes (or print `[STRESS] n/a` stub and exit 0) |
| `make clean` | Remove all build artifacts | Always |

Rules:

- **Stubs, not absences.** A tier a repo does not have yet is a target that prints
  `[<TIER>] n/a: <reason>` and exits 0. A missing target (or a bare directory with
  the same name) is a deviation.
- **Missing tool ≠ failure for optional tiers.** `formal` prints
  `[FORMAL] sby not found; ...` and exits 0 when SymbiYosys is not installed;
  `coverage` skips cleanly without Verilator. CI installs the tools, so a real
  failure still fails there.
- **License-gated flows are not `sim`/`regress`.** A repo whose primary bench needs a
  commercial simulator (`si5_prep`: Xcelium) keeps that flow under its own targets
  (`regression`, `rand_regress`, ...). `sim` runs it only when `xrun` is on PATH and
  otherwise falls back to the license-free RTL smoke; `regress` is always license-free.
- **Non-Make drivers.** `apb-to-mem-all-py` (pytest) and `apb-to-mem-bazel` (Bazel)
  expose the same verbs as thin shims over their native runner.

### Implementation status (2026-10-13 — target-name sweep)

All 18 repos now define every standard target and default to `help`
(`make audit` reports no target warnings). Behaviour behind each name still differs
by repo (the aggregates are supersets of the minimum above); the points below are the
per-repo specifics worth knowing.

| Repo | `stress` is | `formal` is | Notes |
|------|-------------|-------------|-------|
| IP-axi-to-2apbs | `test-stress` (iverilog) | SymbiYosys | |
| IP-ucie-rdi-to-pcie-pipe | n/a stub | SymbiYosys | default goal was `all`, now `help` |
| axi4_to_dfi_ddr | n/a stub | SymbiYosys | |
| chi-to-bow-bridge | n/a stub | SymbiYosys | default goal was `all` (CI now runs `make all`) |
| ucie-cxl-bridge | directed stress | SymbiYosys, sby-guarded | |
| tilelink_to_AXI4 | n/a stub | SymbiYosys | needs `sbt` for every tier |
| cxl_lpddr5x_bridge | directed stress | SymbiYosys, sby-guarded | |
| chi-to-cxl-bridge | directed stress | SymbiYosys, sby-guarded | |
| chi-to-ucie-bridge | directed stress | SymbiYosys, sby-guarded | |
| ucie_rdi_to_pcie6_pipe7 | n/a stub | SymbiYosys | `lint` fails on Verilator 5.020 (SVA `##[a:b]` unsupported); not re-verified on a newer one |
| si5_prep | `iverilog_rand` | SymbiYosys, sby-guarded | gained lint/regress/coverage/ci; `coverage` is an n/a stub (Xcelium) |
| axi-on-ucie-to-mem | `test-random` | SymbiYosys | `regress` is the heavy gate here (`ci` = `regress`) |
| ucie2-pipe7-bridge | n/a stub | SymbiYosys | |
| eth-dj-to-pcie-pipe-bridge | directed stress | SymbiYosys, sby-guarded | |
| eth-dj-pcie-pipe7_1-bridge | n/a stub | n/a stub | already conformant |
| uvm_review | `test-random` | n/a stub | `sim` was a no-op (matched `sim/` dir); now `test` |
| apb-to-mem-all-py | `test-random` | n/a stub | pytest-driven |
| apb-to-mem-bazel | `test-random` | n/a stub | Bazel-driven |

------|------|-----|---------|----------|--------|----|-------------|
| IP-axi-to-2apbs | ✓ | ✓ | ✓ | ✓ (Verilator C++) | ✓ (SymbiYosys) | ✓ | ✓ coverage job |
| IP-ucie-rdi-to-pcie-pipe | ✓ | ✓ | ✓ | ✓ alias | ✓ (SymbiYosys) | ✓ existing | ✓ existing |
| axi4_to_dfi_ddr | ✓ alias | ✓ | ✓ | ✓ (Verilator C++) | ✓ (SymbiYosys) | ✓ existing | ✓ coverage job |
| chi-to-bow-bridge | ✓ | ✓ | ✓ | ✓ alias | ✓ (SymbiYosys) | ✓ | ✓ existing |
| ucie-cxl-bridge | ✓ | ✓ | ✓ | ✓ (Verilator C++) | ✓ (SymbiYosys) | ✓ | ✓ coverage job |
| tilelink_to_AXI4 | ✓ | ✓ (Verilator C++ + cocotb Icarus) | ✓ | ✓ (Verilator C++, 97.1%) | ✓ (SymbiYosys) | ✓ | ✗ |
| cxl_lpddr5x_bridge | ✓ | ✓ (Icarus + cocotb Icarus) | ✓ | ✓ (Verilator C++, 96.9%) | ✓ (SymbiYosys, 6/6) | ✓ | ✓ regress/coverage/cocotb/formal |

---

## Standard CI layout

Every RTL repo should have `.github/workflows/ci.yml` with these jobs:

```
regress   — make regress   (lint + sim, always fast, blocks merge)
coverage  — make coverage  (Verilator --coverage, artifact upload, needs: regress)
formal    — make formal     (SymbiYosys or Yosys, needs: regress, where .sby exists)
```

All jobs run on `ubuntu-latest`. OSS CAD Suite is pinned by
`OSS_CAD_SUITE_VERSION` env var for SymbiYosys repos.

---

## Formal verification standard

- **Tool:** SymbiYosys (`.sby` files). Yosys raw scripts are acceptable as an
  intermediate step but should be migrated to `.sby`.
- **Location:** `verification/formal/` with a `Makefile` exposing per-module
  targets and `all`.
- **Modes:** always include both `bmc` (bounded model check) and `cover`
  (reachability) tasks in each `.sby`.
- **Properties:** kept in a dedicated `*_props.sv` or inline `formal` blocks
  gated on `` `ifdef FORMAL ``.

---

## Coverage standard

- **Tool:** Verilator `--coverage` (OSS-compatible, lcov output).
- **Output:** `coverage.info` (lcov format) at repo root; uploaded as CI artifact.
- **Requires:** a Verilator C++ `sim_main.cpp`; Icarus-only repos need one added.
- **Target floor (aspirational):** ≥ 80% line coverage before calling a module done.

---

## Directory layout standard

Preferred structure (adopted by `ucie-cxl-bridge`; others to migrate gradually):

```
src/                    RTL source files
verification/
  directed/             Icarus or Verilator C++ directed testbench + Makefile
  formal/               SymbiYosys .sby files + Makefile
  uvm/                  VCS UVM bench (local only, not in CI)
doc/ or docs/           Design spec, plan, verification plan
```

Current deviations (tracked in TODO below):
- `IP-axi-to-2apbs`: `test/` + `uvm/vcs/` + `uvm/sv/`
- `IP-ucie-rdi-to-pcie-pipe`: `test/` + `test/uvm/`
- `axi4_to_dfi_ddr`: `test/` + `uvm_dv/` + `formal/` + `syn/`
- `chi-to-bow-bridge`: `test/` + `integration/` + `uvm_bench/` + `vlate_bench/` + `verification/`

---

## TODO list

### Done (2026-10-13 target-name sweep)

- [x] Extend scope from 5–7 repos to all 18 RTL/DV repos; `make audit` now checks
      every standard target and the `help` default goal in each
- [x] Add `stress` (alias to the existing random tier, else an n/a stub) and `help`
      default goal everywhere they were missing
- [x] `formal` no longer hard-fails (exit 127) when `sby` is absent in
      ucie-cxl-bridge, cxl_lpddr5x_bridge, chi-to-cxl-bridge, chi-to-ucie-bridge,
      eth-dj-to-pcie-pipe-bridge
- [x] `si5_prep`: add lint / regress / coverage / formal / ci / stress; make `sim`
      license-free when no Xcelium
- [x] Root `make repos-<target>` runs any standard target across all repos

### Done (2026-05-09 alignment sweep)

- [x] Create `dv_env.mk` at workspace root as canonical tool version pin source
      (`OSS_CAD_SUITE_VERSION`, `COCOTB_PIP_SPEC`)
- [x] Create `dv_audit.sh` — checks all 5 repos for standard targets, CI file name,
      and version pin alignment. Run via `make audit` from workspace root.
- [x] Add `make regress` to workspace root Makefile (iterates all 5 repos)
- [x] Pin `cocotb==1.8.1` in all 4 CI files that install cocotb (was unpinned)
- [x] Rename `IP-ucie-rdi-to-pcie-pipe` CI file: `verilator.yml` → `ci.yml`
- [x] Add `sim` alias to `chi-to-bow-bridge`, `axi4_to_dfi_ddr`, and
      `IP-ucie-rdi-to-pcie-pipe` Makefiles for DV_STANDARDS.md compliance

### Done (2026-05-09 sweep)

- [x] Add `regress`, `lint`, `coverage`, `formal`, `ci` to root Makefile of all 5 repos
- [x] Add CI (`.github/workflows/ci.yml`) to `IP-axi-to-2apbs` (was missing)
- [x] Create root `Makefile` for `ucie-cxl-bridge` (was missing)
- [x] Create `verification/formal/Makefile` for `ucie-cxl-bridge`
- [x] Update `ucie-cxl-bridge` CI to use `make regress` as unified fast gate
- [x] Add `coverage` alias in `IP-ucie-rdi-to-pcie-pipe` (was `regress_cov`)
- [x] Add `formal` stub to `IP-ucie-rdi-to-pcie-pipe` and `IP-axi-to-2apbs`
- [x] Add `lint` + `regress` + `ci` to `chi-to-bow-bridge` root Makefile
- [x] Add `lint` + `regress` + `coverage` + `formal` to `axi4_to_dfi_ddr` root Makefile

---

### Near-term (require significant new code)

- [x] **IP-axi-to-2apbs**: Add Verilator C++ `sim_main_simple.cpp` +
  `sim_main_burst.cpp` for `simple` and `burst` bridges → `make coverage`
  emits `coverage_simple.info` + `coverage_burst.info`. (done 2026-05-09)

- [x] **axi4_to_dfi_ddr**: Add Verilator C++ `sim_main.cpp` (dual-clock
  axi_aclk/dfi_clk harness with DFI PHY model) → `make coverage` emits
  `coverage.info`. (done 2026-05-09)

- [x] **ucie-cxl-bridge**: Add Verilator C++ `sim/sim_main.cpp` targeting
  `cxl_ucie_bridge` → `make coverage` emits `sim/coverage.info`.
  (done 2026-05-09)

- [x] **IP-axi-to-2apbs**: Add SymbiYosys formal (`verification/formal/`):
  - APB4 handshake invariants (PSEL → PENABLE in 1 cycle; PSEL/PENABLE deassert
    cycle after PREADY accepted; PSEL0 ∧ PSEL1 = 0 mutual exclusion)
  - BVALID/RVALID deassert cycle after handshake (no phantom responses)
  - Cover goals: write and read transactions reach completion
  (done 2026-05-10; `apb4_simple_props.sv` + `apb4_simple.sby`)

- [x] **IP-ucie-rdi-to-pcie-pipe**: Add SymbiYosys formal (`verification/formal/`):
  - P1: `wr_ready = !wr_full` (no write accepted while full)
  - P4: registered output stable while `rd_ready` low (`rd_valid`, `rd_data`,
    `rd_error` hold unchanged)
  - Cover: FIFO fills to full (step 5), then drains to empty (step 9)
  Note: production RTL uses SV struct literals + `return` that Yosys cannot
  parse; `ucie_fifo_cdc_model.v` is a plain-Verilog equivalent used for formal.
  P2 (occupancy ≤ DEPTH) and P3 (full/empty mutex) require k-induction to
  close the 2-cycle sync-chain transient; deferred. (done 2026-05-10)

- [x] **chi-to-bow-bridge**: Add SymbiYosys formal (`verification/formal/`):
  - P1 no-double-alloc (txnid slot free at chi_push), P2/P3 FIFO bounds,
    P4 no REQ_HDR during write-data burst — BMC depth 20, proved.
  - Cover C1 WRITE_ACK (step 8) and C2 READ_RESP (step 10) reachable.
  - Root cause found during formal: `bow_pop` driven by two always blocks;
    Yosys resolved conflict to constant 0, silencing RX FIFO pops for
    READ_RESP path. Fixed by consolidating bow_pop reset into the RX block.
  - Added `dbg_rsp_rem_byte0` / `dbg_rsp_opcode0` debug outputs + invariant
    assumes to keep SMT formula tractable. (done 2026-05-12)

- [x] **axi4_to_dfi_ddr**: Migrate `formal/fifo_safety_top.sv` + Yosys `.ys`
  scripts to SymbiYosys `.sby` format. Added `verification/formal/Makefile`,
  `async_fifo.sby` (bmc + cover tasks), updated `fifo_safety_top.sv` with
  cover goals (fill-to-full then drain-to-empty). `make formal` now delegates
  to `verification/formal/`; falls back to legacy Yosys `formal-fifo` if
  sby is absent. (done 2026-05-10)

---

### Medium-term (infrastructure / policy)

- [x] **Coverage CI job**: Added `make coverage` as a CI job with artifact upload
  to IP-axi-to-2apbs, axi4_to_dfi_ddr, and ucie-cxl-bridge. (done 2026-05-09)
  Remaining: wire coverage gate (80% floor enforcement) and chi-to-bow-bridge.

- [ ] **chi-to-bow-bridge**: Wire `make coverage` (= `vlate_bench/coverage`) into
  the CI `vlate-bench` job as an artifact upload. Already works locally via
  `make oss-regress-coverage`.

- [x] **Rename IP-ucie-rdi-to-pcie-pipe CI file**: `verilator.yml` →
  `ci.yml` (done 2026-05-09; update badge links in README.md if needed).

- [ ] **Assertion inventory**: Add `ASSERTIONS.md` to each repo listing every
  checked property, the file it lives in, and the simulator/tool that checks it.

- [ ] **UVM CI path**: Decide policy — VCS license in CI (self-hosted runner) or
  keep UVM local-only. Document the decision in each repo's `uvm*/README.md`.

---

### Long-term (directory layout refactor)

- [ ] Migrate `IP-axi-to-2apbs` to `verification/` umbrella:
  `test/` → `verification/directed/`, `uvm/` → `verification/uvm/`.
  Update all Makefile paths, CI, and README.

- [ ] Migrate `IP-ucie-rdi-to-pcie-pipe` to `verification/` umbrella:
  `test/` → `verification/directed/`, `test/uvm/` → `verification/uvm/`.

- [ ] Migrate `axi4_to_dfi_ddr` to `verification/` umbrella:
  `test/` → `verification/directed/`, `uvm_dv/` → `verification/uvm/`,
  `formal/` → `verification/formal/`.

- [ ] Migrate `chi-to-bow-bridge` `test/` and `integration/` under `verification/`
  (vlate_bench and uvm_bench can stay as named subdirs given their distinct stacks).

- [ ] Central **DV policy review**: after all repos adopt `verification/` layout,
  review and update this `DV_STANDARDS.md` to remove the deviation notes.
