# DV Standards — RTL Workspace

**Applies to:** `IP-axi-to-2apbs`, `IP-ucie-rdi-to-pcie-pipe`, `axi4_to_dfi_ddr`,
`chi-to-bow-bridge`, `ucie-cxl-bridge`

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
| `make clean` | Remove all build artifacts | Always |

### Implementation status (2026-05-09)

| Repo | lint | sim | regress | coverage | formal | ci | CI workflow |
|------|------|-----|---------|----------|--------|----|-------------|
| IP-axi-to-2apbs | ✓ | ✓ | ✓ | stub | stub | ✓ | ✓ added |
| IP-ucie-rdi-to-pcie-pipe | ✓ | ✓ | ✓ | ✓ alias | stub | ✓ existing | ✓ existing |
| axi4_to_dfi_ddr | ✓ alias | ✓ | ✓ | stub | ✓ (Yosys) | ✓ existing | ✓ existing |
| chi-to-bow-bridge | ✓ | ✓ | ✓ | ✓ alias | stub | ✓ | ✓ existing |
| ucie-cxl-bridge | ✓ | ✓ | ✓ | stub | ✓ (SymbiYosys) | ✓ | ✓ updated |

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

- [ ] **IP-axi-to-2apbs**: Add Verilator C++ `sim_main.cpp` for `simple` and
  `burst` bridges → enables real `make coverage` (Verilator `--coverage`).
  See `doc/PLAN.md` Near-term item 1.

- [ ] **axi4_to_dfi_ddr**: Add Verilator C++ `sim_main.cpp` for bridge top →
  enables real `make coverage`. See `doc/FULL_FUNCTIONALITY_PLAN.md` Phase 6.

- [ ] **ucie-cxl-bridge**: Add Verilator C++ `sim_main.cpp` targeting
  `cxl_ucie_bridge` → enables real `make coverage`. See `doc/PLAN.md` Phase 7.

- [ ] **IP-axi-to-2apbs**: Add SymbiYosys formal (`verification/formal/`):
  - APB4 handshake invariants (PSEL → PENABLE ≤ 1 cycle; no overlap)
  - AXI same-ID response ordering (no reorder, no loss)
  - No-deadlock BMC (bridge always drains a burst)
  See `doc/PLAN.md` Medium-term item 4.

- [ ] **IP-ucie-rdi-to-pcie-pipe**: Add SymbiYosys formal (`verification/formal/`):
  - Async FIFO invariants (no overflow, no underflow, in-order readout)
  - RDI/PIPE handshake properties (data stable while valid)
  See `docs/verification_plan.md` (Coverage and formal section).

- [ ] **chi-to-bow-bridge**: Add SymbiYosys formal (`verification/formal/`):
  - BoW flit ordering invariants
  - Outstanding-txn table: no double-alloc, no stall leak
  See `docs/PLAN.md` Medium-term directions.

- [ ] **axi4_to_dfi_ddr**: Migrate `formal/fifo_safety_top.sv` + Yosys `.ys`
  scripts to SymbiYosys `.sby` format. Add `verification/formal/Makefile`.
  Keep `make formal` pointing to the new location.

---

### Medium-term (infrastructure / policy)

- [ ] **Coverage CI gate**: Add `make coverage` as a required CI job (not just
  artifact upload) once C++ wrappers exist. Set floor at 80% line coverage.
  Start with `IP-ucie-rdi-to-pcie-pipe` (already has Verilator C++).

- [ ] **chi-to-bow-bridge**: Wire `make coverage` (= `vlate_bench/coverage`) into
  the CI `vlate-bench` job as an artifact upload. Already works locally via
  `make oss-regress-coverage`.

- [ ] **Rename IP-ucie-rdi-to-pcie-pipe CI file**: `verilator.yml` →
  `ci.yml` for consistency. Update any badge links in `README.md`.

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
