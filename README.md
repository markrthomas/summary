# Project Repositories Summary

**Snapshot dates** here (the **inspected on** line, maintenance section headings, and **Verification stamp**) use **this workstation's local calendar day** — i.e. what `date` reports under your current **`TZ`** / system clock — **not** UTC, unless a note says otherwise.

This directory contains 16 Git repositories. The notes below reflect each repo's local `README.md`, top-level files, and Git status as inspected on **2026-07-05**.

## 2026-05-09 maintenance update

- Re-surveyed all nine sub-repos for newest commits, branch alignment, and working-tree noise.
- **Verification stamp:** on **2026-05-09**, each clone matches **`origin`** (**ahead 0 / behind 0**) and local dirt matches the **Repository notes** section (`NOTES` in four repos; see notes) where called out.
- **Plan files added:** `IP-axi-to-2apbs`, `MiT_capstone_beetle_kill`, `pc-wsl-github-starter`, `riscv_test_asm_qemu`, and `ucie-cxl-bridge` each now have a `PLAN.md` in their `doc/` or `docs/` directory. The four repos that already had plans (`IP-ucie-rdi-to-pcie-pipe`, `axi4_to_dfi_ddr`, `chi-to-bow-bridge`, `snn-crossbar-model`) retain their existing plan documents.
- **No RTL or code changes** in this sweep — documentation and plans only.

Prior sweep (**2026-05-06**) covered: `chi-to-bow-bridge` PR #19 (XeLaTeX/DejaVu PDF defaults), `IP-axi-to-2apbs` UVM docs refresh, `IP-ucie-rdi-to-pcie-pipe` UVM PDF polish, `axi4_to_dfi_ddr` UVM DV environment for VCS, `ucie-cxl-bridge` `.gitignore` cleanup. Prior-prior sweep (**2026-05-02**) covered Verilator coverage on UCIe IP, AXI/DDR checkpoints, RISC-V layout refactor, SNN visualization/roadmap, CXL Phase 3 docs, AXI-2APBS Makefile wiring, and `pc-wsl-github-starter` CLI/tooling upgrades.

## At a glance

- `IP-axi-to-2apbs`: AXI to dual-APB4 bridge RTL. Stack: Verilog, Icarus, UVM. State: `main`, clean except untracked `sim_regblock`. Plan: `doc/PLAN.md`.
- `IP-ucie-rdi-to-pcie-pipe`: UCIe RDI to PCIe PIPE bridge RTL. Stack: SystemVerilog, Verilator, vendor simulators. State: `main`, clean. Plan: `docs/verification_plan.md`.
- `MiT_capstone_beetle_kill`: Forest bark beetle object detection. Stack: Python, PyTorch, pytest. State: `main`, clean. Plan: `docs/PLAN.md`.
- `axi4_to_dfi_ddr`: AXI4 to DFI / DDR bridge RTL. Stack: Verilog, Icarus, Verilator, Yosys, Pandoc, optional VCS/UVM DV. State: `main`, clean. Plan: `doc/FULL_FUNCTIONALITY_PLAN.md`.
- `chi-to-bow-bridge`: CHI to BoW bridge starter. Stack: Verilog, Cocotb, Icarus, integration + **`vlate_bench`** Verilator TB, optional **`uvm_bench`** VCS/UVM, Pandoc/XeLaTeX PDFs. State: `main`, clean. Plan: `docs/PLAN.md`.
- `chi-to-cxl-bridge`: CHI to CXL.mem bridge RTL (compact 64-bit protocol abstraction). Stack: Verilog/SystemVerilog, Icarus, Verilator, SymbiYosys, cocotb. State: `main`, dirty. Plan: `doc/PLAN.md`.
- `chi-to-ucie-bridge`: CHI to UCIe adapter-link bridge (Phase 1 RTL scaffold + UVM TB underway). Stack: Verilog/SystemVerilog, Icarus, Verilator, UVM. State: `master`, clean. Plan: `doc/PLAN.md`.
- `chipyard`: Upstream Berkeley UCB-BAR Chipyard SoC framework (Chisel, Rocket Chip, BOOM, FireSim, Hammer). Stack: Chisel/Scala, sbt, mill, Verilator. State: `main`, dirty. Plan: upstream (no local plan).
- `chisel-playground`: Chisel project template / starter (post-Chisel-Bootcamp). Stack: Chisel3, Mill/SBT, Verilator, JDK 11+. State: `master`, clean except untracked `.github/`, `.gitignore`, and 20 more. Plan: upstream (no local plan).
- `cxl_lpddr5x_bridge`: CXL.mem to LPDDR5X bridge RTL. Stack: Verilog/SystemVerilog, Icarus, Verilator, SymbiYosys, cocotb. State: `main`, clean. Plan: `doc/PLAN.md`.
- `pc-wsl-github-starter`: WSL + GitHub starter workflow. Stack: Python, Typer, pytest, GitHub Actions. State: `main`, clean. Plan: `docs/PLAN.md`.
- `riscv_test_asm_qemu`: RISC-V cross-compile and QEMU experiments. Stack: RISC-V GNU toolchain, QEMU. State: `master`, clean. Plan: `docs/PLAN.md`.
- `si5_prep`: AXI4-Lite slave RTL + full UVM TB (interview prep). Stack: SystemVerilog, UVM, Xcelium/Questa/VCS, Icarus, Verilator, JasperGold/VC Formal. State: `main`, clean. Plan: `PLAN.md`.
- `snn-crossbar-model`: Spiking neural network crossbar model. Stack: Python, PyTorch, C++, SystemC, Verilog, pytest. State: `main`, clean except untracked `NOTES`. Plan: `doc/roadmap.md`.
- `tilelink_to_AXI4`: TileLink → AXI4/AXI4-Lite + TL-C bridges in Chisel (TLCToCHI Issue-E in progress). Stack: Chisel, Verilator C++ TB, SymbiYosys, cocotb. State: `main`, clean. Plan: `doc/PLAN.md` (+ `doc/CHI_PLAN.md`).
- `ucie-cxl-bridge`: UCIe to CXL bridge RTL (Phases 1–6). Stack: Verilog/SystemVerilog, Icarus, Verilator, SymbiYosys. State: `main`, clean. Plan: `doc/PLAN.md`.

## Repository notes

### `IP-axi-to-2apbs`

- Purpose: AXI to 2× APB4 bridge RTL with self-checking testbenches.
- Highlights: separate simple and burst bridge variants, APB read wait-state test sweeps (`make test-simple-ws-sweep`), bridge design contract in `doc/design_contract.md`, UVM README maps / PDF-oriented trees, **`readme-md-pdfs`** Make target.
- Current state: `main` aligned with `origin/main`; **untracked** `sim_regblock` locally.
- Last commit: `544e170` — "feat: add AXI3-Lite 32×32 register block with full verification stack".
- **Plan (`doc/PLAN.md`):** Near-term — UVM sequence/scoreboard closure, negative protocol-error tests, `make ci` + GitHub Actions gate. Medium-term — SymbiYosys formal (APB4 handshake + AXI ordering + no-deadlock), burst-length sweep, dual-slave stress. Long-term — AXI4 QoS/ID tagging, APB3 compatibility mode, synthesis flow.

### `IP-ucie-rdi-to-pcie-pipe`

- Purpose: production-style SystemVerilog bridge from UCIe 1.0 RDI to PCIe Gen4 PIPE.
- Highlights: dual-clock CDC with Gray-code pointer synchronization, per-lane elastic FIFOs, CRC32, CDC assertion monitors, self-checking scoreboard, Verilator coverage CI, FIFO stress verification plan, NUM_LANES=1 smoke test, reusable IP v1.0.0 baseline tag, enhanced UVM docs + PDF formatting.
- Notes: canonical RTL lives at the repo root; `src/` and `test/` subdirectories contain thin `` `include `` wrappers for EDA tools that prefer that layout. `make verilator` and `make lint` compile the root files directly.
- Current state: clean working tree on `main`.
- Last commit: `fed56ce` — "dv: add SymbiYosys formal and CI/Makefile alignment".
- **Plan (`docs/verification_plan.md`):** Near-term — UVM functional coverage groups, PIPE backpressure agent, RX-path scoreboard, CRC-in-UVM. Medium-term — formal async FIFO invariants + handshake properties (SymbiYosys). Long-term — PIPE valid⇒data hold RTL + monitor policy if integrators require it.

### `MiT_capstone_beetle_kill`

- Purpose: PyTorch object-detection pipeline for aerial / oblique forest bark beetle survey imagery with Pascal-VOC-style XML annotations.
- Highlights: Faster R-CNN (ResNet50-FPN) training and inference, per-class precision/recall/F1 evaluation, CPU and GPU smoke tests, pytest suite, confidence-threshold tuning script, and dataset/process docs.
- Current state: clean working tree on `main`.
- Last commit: `f844e8b` — "docs: add development plan (PR curves, ONNX export, augmentation, CLI)".
- **Plan (`docs/PLAN.md`):** Near-term — PR curve output + AP per class, confusion matrix + per-image drill-down, reproducible dataset splits (seed + manifest), ONNX export. Medium-term — data augmentation pipeline, backbone comparison (MobileNetV3 / ResNet34), threshold/NMS grid-search, inference CLI (argparse/Typer). Long-term — dataset expansion, semi-supervised labeling, tile-based inference, web demo, edge deployment.

### `axi4_to_dfi_ddr`

- Purpose: AXI4 slave to JEDEC DFI-style bridge for a DDR PHY / memory-controller path.
- Highlights: gray-code async FIFOs for CDC, open-page SDRAM scheduler with per-bank PRE/ACT/CAS timing (`MC_T_RP`, `MC_T_RCD`, `MC_T_RAS`, `MC_T_WR`), optional refresh walk, AXI SLVERR error paths, elaboration-time parameter checks, Verilator lint, Yosys synthesis/formal hooks, generated PDF/HTML design spec, full-functionality roadmap (`doc/FULL_FUNCTIONALITY_PLAN.md`), **UVM DV environment for VCS**.
- Current state: clean working tree on `main`.
- Last commit: `06a4805` — "dv: add coverage harness, migrate formal to SymbiYosys, CI alignment".
- **Plan (`doc/FULL_FUNCTIONALITY_PLAN.md`):** Phase 1 (active) — CDC and response-ordering hardening (FIFO formal, SLVERR queue, second-simulator). Phase 2 — module split (AXI front-end, CDC queues, scheduler, DFI adapter). Phase 3 — AXI feature completion (INCR bursts, narrow/unaligned, FIXED/WRAP). Phase 4 — JEDEC scheduling (tRFC, tRRD, tFAW, bank-group, REF). Phase 5 — DFI fidelity (phase lanes, update/LP handshakes). Phase 6 — verification infrastructure (SVAs, randomized seeds, coverage). Phase 7 — synthesis and integration readiness.

### `chi-to-bow-bridge`

- Purpose: starter CHI-to-BoW bridge that packetizes simplified CHI requests into BoW flits and reconstructs responses.
- Highlights: Cocotb + Icarus unit/integration flows; integration top with reference BFM; OSS **`vlate_bench/`** Verilator + C++ parity TB (lint/run/coverage hooks); optional **`uvm_bench/`** Synopsys VCS / UVM bench with onboarding/quickref PDFs; integration protocol checker bind coverage across flows; BoW RX inject path + unknown-txn **`RSP_HDR`** parity; OSS regression Makefile targets; Markdown→PDF via Pandoc **XeLaTeX** + **DejaVu** (`docs/pandoc-pdf-defaults.yaml`, `docs/pandoc-pdf-header.tex`).
- Current state: clean working tree on `main`.
- Last commit: `a94e0e7` — "Implement duplicate, orphan, and illegal response header integration scenarios under Cocotb and Verilator (#23)".
- **Plan (`docs/PLAN.md`):** Near-term — deeper integration error-path via `bow_inj_*` (dup/orphan payloads), machine-readable golden-payload header export. Medium-term — CHI fidelity (split REQ/RSP/DAT channels), distinct write-data beats per REQ_DATA, QoS/fairness arbiter. Long-term — industry BoW/CHI compliance suites, performance modeling (throughput vs FIFO depth), power-aware link assumptions.

### `chi-to-cxl-bridge`

- Purpose: experimental CHI ↔ CXL.mem bridge using a compact 64-bit protocol abstraction (not a full wire encoding) — translates CHI requests into CXL.mem M2S flits and reconstructs S2M responses as CHI responses.
- Highlights: dual-clock async FIFOs for CDC, per-class credit-based flow control, CRC-checked S2M responses, link-drain gating, directed + stress simulation reaching 100% line coverage, interface SVA, SymbiYosys formal proofs. Phase 3a in progress on structured flits + bidirectional translation flow.
- Current state: `main`; **dirty** (3 uncommitted change(s)); **untracked** `src/tag_manager.v` locally.
- Last commit: `5423a71` — "Phase 3a: Implement structured flits and bidirectional translation flow".
- **Plan (`doc/PLAN.md`):** Near-term — finish Phase 3 structured-flit translation flow, expand stress sim, broaden formal cover set. Medium-term — closer CXL.mem M2S/S2M opcode fidelity, multi-beat payload transport, UVM bench. Long-term — wire-level CXL.mem encoding, performance modeling, RAS / poison-flit handling.

### `chi-to-ucie-bridge`

- Purpose: experimental CHI Request-Node ↔ UCIe adapter-link bridge — translates CHI requests to checksum-protected UCIe adapter headers (and optional data) and returns UCIe completions as CHI `Comp` / `CompData` responses.
- Highlights: Phase 1 RTL scaffold with `chi_to_ucie_bridge.v` top, dual-clock CDC FIFOs / 2-flop synchronizers, reset + link-drain gating, checksum-protected UCIe headers, self-checking directed testbench. UVM testbench foundation in progress (generic agents/drivers/items under `verification/uvm/`).
- Current state: clean working tree on `master`.
- Last commit: `fe2a189` — "Coverage: add coverage-report and coverage-html Makefile targets".
- **Plan (`doc/PLAN.md`):** Near-term — finish UVM agents/sequences, integrate scoreboard, baseline coverage. Medium-term — bit-closer UCIe adapter modeling, formal CDC / handshake properties, multi-lane scaling. Long-term — full UCIe wire-shape fidelity, end-to-end CHI-UCIe-CHI loopback in a sysmodel.

### `chipyard`

- Purpose: local clone of the upstream Berkeley UCB-BAR **Chipyard** Chisel-based SoC framework (Rocket Chip, BOOM, CVA6, Gemmini/NVDLA accelerators, FireSim, Hammer VLSI flow, FireMarshal).
- Highlights: large upstream tree — reference for RISC-V SoC bring-up and Chisel patterns. Workspace install state: paused at step 5 (sbt pre-compile), awaiting WSL2 RAM bump; `conda-reqs/chipyard-base.yaml` locally edited to sysroot 2.35.
- Current state: `main` aligned with `origin/main`; **dirty** (7 uncommitted change(s)); **untracked** `conda-reqs/chipyard-base.yaml.bak` locally.
- Last commit: `48f904ae` — "fix: firechip CTCFireSimConfig to match new CTC changes (#2333)".
- **Plan:** upstream-managed; no local PLAN.md. Local task: complete sbt pre-compile and continue Chipyard install once WSL2 RAM is bumped.

### `chisel-playground`

- Purpose: Chisel project template / starter, set up post-Chisel-Bootcamp for greenfield Chisel3 experiments.
- Highlights: Mill + SBT build, bootstrap `./mill`, JDK 11+, Verilator for `svsim` test path. Pairs with the Coursier-managed Chisel/Scala toolchain (`~/.local/share/coursier/bin`) and firtool `1.148.0` in `~/.local/bin`.
- Current state: `master`; **untracked** `.github/`, `.gitignore`, `.mill-jvm-opts`, `AccelMMIO.sv`, and 18 more locally.
- Last commit: (none — no commits yet on `master`).
- **Plan:** upstream template; no local PLAN.md. Local task: stand up a first `MyModule` and Verilator test once the project goal is chosen.

### `cxl_lpddr5x_bridge`

- Purpose: bridge RTL translating CXL.mem (M2S/S2M) traffic to an LPDDR5X-style memory interface with credit-based flow control and clock-domain crossing.
- Highlights: `async_fifo` Gray-pointer CDC, `credit_counter` / `credit_pulse_sync` flow control, `reset_sync` / `reset_drain` reset handling, per-message CRC validation with bad-CRC reject; OSS DV stack — Icarus self-checking directed TB (opcodes, error injection, 1:1/2:1/1:3 clock ratios, backpressure stress), 12 cocotb UVM-equivalent tests, SymbiYosys BMC+cover on `credit_counter` / `reset_drain` / bridge top (6/6 PASS), Verilator C++ coverage harness at 96.9% line coverage, concurrent SVA on all four valid/ready interfaces (Verilator `--assert` + proven in formal); root `Makefile` (`lint/sim/regress/coverage/sva/formal/ci`) + `.github/workflows/ci.yml`.
- Current state: clean working tree on `main`.
- Last commit: `9051c66` — "ci: add advisory Verible style-lint job + CI hygiene [plan: Verible lint + format]".
- **Plan (`doc/PLAN.md`):** Near-term — close the residual ~3% coverage (defensive default branches), extended bad-CRC / credit-underflow negatives. Medium-term — raise bridge BMC depth past 16 via k-induction, populate the VCS UVM bench. Long-term — LPDDR5X bank/timing scheduler model, synthesis/timing hooks, Pandoc design-spec PDF.

### `pc-wsl-github-starter`

- Purpose: minimal starter repo for a Windows PC + WSL + GitHub workflow.
- Highlights: Typer/Rich CLI, pytest suite, ruff/mypy linting, venv Makefile, GitHub Actions CI.
- Current state: clean working tree on `main`.
- Last commit: `bcd8797` — "docs: add development plan (pre-commit, CI matrix, uv lock-file)".
- **Plan (`docs/PLAN.md`):** Near-term — pre-commit hooks (ruff + mypy), `make check` target, additional CLI commands (`greet`, `env`), WSL detection utility. Medium-term — GitHub Actions matrix (Python 3.11/3.12/3.13 + Windows leg), `uv` lock-file workflow, cookiecutter/template guide. Long-term — Docker dev container, `make release` with changelog, secrets management example, coverage reporting.

### `riscv_test_asm_qemu`

- Purpose: RISC-V cross-compile and QEMU bring-up experiments covering core ISA fundamentals.
- Highlights: 10 test programs (hello, C++, exit-code, arithmetic, loops, function calls, memory load/store, bitwise ops, shifts, recursion); `make test` builds and verifies all 10 under QEMU with exact output and exit-code checks; source-interleaved disassembly targets; reorganized into `src/asm/`, `src/cpp/`, `docs/`, and `build/` layout.
- Current state: clean working tree on `master`.
- Last commit: `ebef064` — "docs: add development plan (M-mode, RV32/RV64, CSR, FP, atomics)".
- **Plan (`docs/PLAN.md`):** Near-term — explicit RV64I/RV32I build modes (`ARCH`/`ABI` variables + `make test-rv32`), M-mode bare-metal image on `qemu-system-riscv64`, CSR exercises (mstatus/mie/mtvec/mcause), ISA cross-link in `docs/isa_tests.md`. Medium-term — F/D extension floating-point demo, M-mode interrupt + timer (CLINT), A-extension atomics, C++ examples expansion. Long-term — S-mode/hypervisor, GDB integration, Spike dual-sim, FPGA bring-up.

### `si5_prep`

- Purpose: interview-prep AXI4-Lite slave RTL with a full UVM testbench targeting Xcelium, portable to Questa/VCS, with `iverilog` + Verilator backup checks and formal hooks for JasperGold / VC Formal.
- Highlights: FSM-based DUT with `_sva` SVA bind + standalone formal property module, DPI-C golden-model shadow registers, layered UVM TB (driver callbacks, RAL predictor + adapter, scoreboard, virtual sequencer, sequence library), W1C/RC register modeled (REG3) with same-cycle RC-over-W1C priority, round-robin 2:1 AXI4-Lite arbiter for multi-master scenarios, coverage-closure narrative + constraint-solver comments, TileLink and RISC-V DV companion notes.
- Current state: clean working tree on `main`.
- Last commit: `d0e6a30` — "feat: SymbiYosys k-induction prove on the TL-UL bridge (T1.4)".
- **Plan (`PLAN.md`):** Near-term — CDV closure loop, checker/predictor scoreboard split (TLM-based), `uvm_sequence_library` with weighted selection + `randsequence` block, back-pressure (toggling `bready`/`rready`) and protocol-error-injection sequences, mid-simulation reset sequence. Medium-term — RAL backdoor via DPI, custom RAL field-access type for W1C+RC, in-monitor performance measurement (latency/throughput), `uvm_transaction` recording, custom drain phase domain. Long-term — liveness SVA with must-fire semantics, formal-extraction-ready property package.

### `snn-crossbar-model`

- Purpose: spiking neural network targeting hardware-oriented crossbar (RRAM/PCM) design, with four-way fixed-point cross-check across Python, C++, SystemC, and Verilog RTL.
- Highlights: `snntorch`-based training with noise-aware QAT, weight-level × timestep × hidden-dim sweep, Gaussian noise robustness evaluation, bit-identical four-way cross-check (Python == C++ == SystemC == Verilog), synthesizable Verilog core (`snn_core_fixed.v`) with multi-cycle FSM and `start/done/busy` handshake, visualization tool (`scripts/visualize.py`), and 38-test pytest suite.
- Current state: `main` aligned with `origin/main`; **untracked** `NOTES` locally.
- Last commit: `cb14e44` — "Add development roadmap".
- **Plan (`doc/roadmap.md`):** Near-term — `CLAUDE.md`, `evaluate.py` fc2 shape check, `to_hex_signed()` stdlib fix, wire `validate_asic_compat()` into `train.py`. Medium-term — golden accuracy CI baseline (2-epoch smoke train, acc floor), RTL parameter sweep in CI (hidden_dim=4 / num_steps=1), document training/cross-check arithmetic gap, `crossbar_report()` delta from `asic_spec.json`. Long-term — pipelined/streaming RTL throughput, Yosys synthesis + area/power, convolutional front-end extension, hardware-in-the-loop gate-level verification.

### `tilelink_to_AXI4`

- Purpose: TileLink → AXI4 / AXI4-Lite / TL-C → CHI bridges, written in Chisel and verified with a Verilator C++ testbench, SymbiYosys formal proofs, and cocotb.
- Highlights: **TLUHToAXI4** (TL-UH → AXI4 master; `Get`/`PutFullData`/`PutPartialData`/`Hint`/`ArithmeticData`/`LogicalData`; up to 64-byte bursts on a 64-bit data path; `source` → AXI ID); **TLULToAXILite** (TL-UL → AXI4-Lite control-plane bridge, single-beat 32/64-bit); **TLUCToAXI4** (TL-C wire shape without coherence; full TL-UH set + `AcquireBlock`/`AcquirePerm`/`Release`/`ReleaseData`, grants Tip on Acquire, TL-B tied off); **TLCToCHI** in progress — Stage 1 of 7 landed (CHI Issue-E RN-F coherent path, snoops, dirty writeback, GrantAck). CI pinned to OSS CAD Suite **2026-04-13** (Verilator 5.047).
- Current state: clean working tree on `main`.
- Last commit: `0df231a` — "CI: pin OSS CAD Suite to 2026-04-13 (Verilator 5.047)".
- **Plan (`doc/PLAN.md` + `doc/CHI_PLAN.md`):** Near-term — TLCToCHI Stage 2 functional behavior (Acquire/Probe/Grant flows past the skeleton), formal coverage on the three completed bridges. Medium-term — TLCToCHI Stages 3–7 (snoop pipeline, dirty writeback, GrantAck flow, multi-core soak). Long-term — performance modeling (throughput vs FIFO depth), gate-level co-simulation, integration with a Chipyard / Rocket-Chip top.

### `ucie-cxl-bridge`

- Purpose: experimental UCIe Adapter Layer to CXL.io / CXL.cache / CXL.mem bridge.
- Highlights: six completed phases — Phase 1 typed 64-bit packet model and CXL.io ↔ UCIe translation; Phase 2 full packet taxonomy (CXL.io / CXL.mem / CXL.cache + completions) with XOR checksum; Phase 3 per-direction credit counters, posted/non-posted ordering split with posted-priority arbiter; Phase 4 `reset_drain` link-state FSM; Phase 5 dual-clock async FIFO architecture; Phase 6 granular protocol opcodes + integrated cross-domain credit counters. Verilator lint clean; SymbiYosys formal on sync_fifo, reset_drain, and bridge top.
- Current state: clean working tree on `main`.
- Last commit: `e94e227` — "dv: add Verilator coverage harness and CI alignment".
- **Plan (`doc/PLAN.md`):** Phase 7 — multi-beat payload transport (payload FIFO, arbiter sequencing, formal payload safety). Phase 8 — UVM constrained-random closure (active CXL driver, scoreboard, 95% functional coverage). Phase 9 — credit advertisement protocol (external grant/return handshake, credit-safety formal property). Near-term backlog — payload FIFO formal property file, UVM scoreboard wiring, CI directed-test GitHub Actions job, opcode decode unit test.

## Overall observations

- Most of the sixteen repositories are hardware / verification projects: Verilog/SystemVerilog RTL bridges (AXI, APB, CHI, CXL, UCIe, BoW, LPDDR5X, DFI/DDR, PCIe PIPE, AXI4-Lite slave), Chisel-based TileLink ↔ AXI / TL-C ↔ CHI bridges, the upstream Berkeley **Chipyard** SoC framework, a **Chisel** starter template, and a spiking neural network with four-way RTL cross-check.
- `MiT_capstone_beetle_kill` is the sole ML/Python project; `riscv_test_asm_qemu` is the sole bare-metal RISC-V toolchain project; `pc-wsl-github-starter` is the only pure-tooling repo.
- Most repos track **`main`** / **`master`** in lockstep with their remotes; a few clones carry **untracked** scratch (`NOTES`, sim build dirs, UVM PDFs) — see each section.
- **Most local repos have plan documents.** Upstream-managed repos (`chipyard`, `chisel-playground`) intentionally rely on upstream roadmaps and don't carry a local `PLAN.md`.
- **Workspace PDF**: this summary's **`make pdf`** uses the same **XeLaTeX + DejaVu** stack as **`chi-to-bow-bridge`** (`.pandoc-pdf-defaults.yaml` + `.pandoc-header.tex`).
- **Default `make` target** is `update-readme`, which regenerates this file's dynamic facts (repo count, inspected-on date, per-repo `State`, `Current state`, and `Last commit`) from `git`. Hand-curated prose (Purpose / Highlights / Plan) is left untouched.
