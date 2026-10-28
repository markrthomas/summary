# DV Standards — RTL Workspace

**Applies to** (the bridge IP repos currently in this workspace): `axi-on-ucie-to-mem`,
`eth-dj-pcie-pipe7_1-bridge`, `pcie-on-ucie-3d`, `ucie2-pipe7-bridge`.

`dv_audit.sh` (`make audit`) **auto-discovers** these — every immediate subdirectory
that is a git repo with a root `Makefile` is audited, so a newly cloned repo is
covered without editing the script. (Earlier generations — `IP-axi-to-2apbs`,
`IP-ucie-rdi-to-pcie-pipe`, `axi4_to_dfi_ddr`, `chi-to-bow-bridge`, `ucie-cxl-bridge`,
`tilelink_to_AXI4`, `cxl_lpddr5x_bridge` — are no longer checked out here.)

---

## Standard Makefile targets

Every RTL repo must expose these root-level targets with consistent semantics:

| Target | What it runs | Must exit 0 |
|--------|-------------|-------------|
| `make lint` | Verilator `--lint-only -Wall` on all RTL modules | Always |
| `make sim` | Primary directed simulation (Icarus or Verilator C++) | Always |
| `make regress` | `lint` + `sim` — **the fast CI gate** | Always |
| `make coverage` | Verilator `--coverage` simulation + `lcov` report | Yes (or print stub message and exit 0) |
| `make formal` | SymbiYosys BMC + cover on key modules | Yes (or print stub and exit 0) |
| `make ci` | `regress` + `coverage` + `formal` — comprehensive local run | Always |
| `make stress` | Stress / randomized simulation (if applicable) | Always |
| `make tools` | Verify the toolchain and install what is missing (light tiers via apt+pip; heavy from-source builds opt-in via `TOOLS_HEAVY=1`, else reported) | Always |
| `make tools-check` | Verify the toolchain only — install nothing; **non-zero exit iff a *core* tool is absent** (CI/dry-run safe) | Yes (iff core tools present) |
| `make clean` | Remove all build artifacts | Always |

### Implementation status (2026-10-28 — audit auto-discovery + `tools`/`tools-check` standard)

Run `make audit` for the live per-repo result; the audit now also checks for
`CLAUDE.md`, `tools`/`tools-check`, and an accepted cocotb pin.

| Repo | lint/sim/regress | coverage | formal | tools/-check | CLAUDE.md | cocotb |
|------|------------------|----------|--------|--------------|-----------|--------|
| axi-on-ucie-to-mem | ✓ | ✓ (Verilator C++, floor 85%) | ✓ (Yosys slang + btormc) | — (add) | ✓ | 1.9.2 |
| eth-dj-pcie-pipe7_1-bridge | ✓ | ✓ (Verilator C++, floor 80%) | ✓ (SymbiYosys + yices) | — (add) | ✓ (on `main`) | 1.8.1 |
| pcie-on-ucie-3d | ✓ | ✓ (Verilator C++, floor 99%) | ✓ (SymbiYosys + yices) | — (add) | ✓ | 1.8.1 |
| ucie2-pipe7-bridge | ✓ | ✓ (advisory line cov) | ✓ (SymbiYosys bounded) | ✓ | ✓ | 1.9.2 |

---

## Toolchain standard

The canonical tool version pins live in **`dv_env.mk`** at the workspace root (the
single source of truth the audit reads). Each repo's `Dockerfile` remains the
authoritative, buildable recipe; `dv_env.mk` is the shared baseline those are
checked against.

| Tool | Pin (`dv_env.mk`) | Notes |
|------|-------------------|-------|
| Verilator | `VERILATOR_VERSION` 5.050 (≥ `VERILATOR_MIN` 5.030) | **from source** for the UVM `--binary` flow; apt is too old. **Never set `VERILATOR_ROOT`.** |
| Icarus | `ICARUS_MIN` ≥ 12 | SV package syntax; Ubuntu 24.04 apt = 12, 22.04 apt = 11 (too old). |
| Yosys + slang | `YOSYS_REF` | native `read_slang` frontend, from source; for `make formal`. |
| SymbiYosys (sby) | — | from source; `make formal`. |
| Formal solver | `YICES_VERSION` 2.6.5 | yices preferred (memory-light); apt z3 can OOM on deep covers. |
| SystemC | `SYSTEMC_MIN` 2.3.3 | apt `libsystemc-dev`. |
| cocotb | one of `COCOTB_ACCEPTED` (1.8.1 or 1.9.2) | workspace mid-migration; converge later. |
| pyuvm / pyvsc | `PYUVM_PIP_SPEC` / `PYVSC_PIP_SPEC` | pip. |

Every repo exposes **`make tools`** (verify + install missing; heavy from-source
builds opt-in via `TOOLS_HEAVY=1`) and **`make tools-check`** (verify only; non-zero
exit iff a *core* tool is absent — safe as a CI/audit gate), backed by a vendored
`tools/check_tools.sh` driven by `dv_env.mk`. `make tools-check` is additive and is
**not** wired into `regress`/`ci` (it audits the environment, it doesn't gate RTL).

## Standard CI layout

Every RTL repo should have `.github/workflows/ci.yml` with these jobs:

```
regress   — make regress   (lint + sim, always fast, blocks merge)
coverage  — make coverage  (Verilator --coverage, artifact upload, needs: regress)
formal    — make formal     (SymbiYosys or Yosys, needs: regress, where .sby exists)
```

All jobs run on `ubuntu-latest` (or inside the repo's toolchain image, whose
`Dockerfile` pins every tool version).

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

### Done (2026-05-09 alignment sweep)

- [x] Create `dv_env.mk` at workspace root as canonical tool version pin source
      (`COCOTB_PIP_SPEC`)
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
