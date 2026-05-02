# Project Repositories Summary

This directory contains 9 Git repositories. The notes below reflect each repo's local `README.md`, top-level files, and Git status as inspected on 2026-05-02.

## 2026-05-02 maintenance update

- Surveyed all 9 sub-repos for new commits, branch changes, and working-tree state.
- `IP-ucie-rdi-to-pcie-pipe`: added Verilator coverage CI job, FIFO stress verification plan, NUM_LANES=1 smoke test, and reusable IP v1.0.0 baseline.
- `axi4_to_dfi_ddr`: new checkpoint commit covering AXI response ordering and FIFO planning.
- `chi-to-bow-bridge`: active branch changed from `codex/bridge-hardening-fixes` to `integration-bow-inject-mux`; added OSS Verilator structural coverage, UVM bench option, and BoW RX inject mux with parity tests.
- `riscv_test_asm_qemu`: reorganized into `src/asm`, `src/cpp`, `docs/`, and `build/` layout.
- `snn-crossbar-model`: added visualization tool (`scripts/visualize.py`), addressed P0/P1/P2 review issues, and added development roadmap.
- `ucie-cxl-bridge`: updated design-spec for Phase 3 (credit/ordering, arbiter lock).
- `IP-axi-to-2apbs`: new commit documenting bridge design contract; follow-up commit wires Makefile to src/test layout and adds extended/parameterized burst TBs.
- `pc-wsl-github-starter`: upgraded to Typer/Rich CLI, pytest, ruff/mypy, and venv-backed Makefile.

## At a glance

- `IP-axi-to-2apbs`: AXI to dual-APB4 bridge RTL. Stack: Verilog, Icarus. State: `main`, clean.
- `IP-ucie-rdi-to-pcie-pipe`: UCIe RDI to PCIe PIPE bridge RTL. Stack: SystemVerilog, Verilator, vendor simulators. State: `main`, clean.
- `MiT_capstone_beetle_kill`: Forest bark beetle object detection. Stack: Python, PyTorch, pytest. State: `codex/review-improvements`, clean.
- `axi4_to_dfi_ddr`: AXI4 to DFI / DDR bridge RTL. Stack: Verilog, Icarus, Verilator, Yosys, Pandoc. State: `main`, clean.
- `chi-to-bow-bridge`: CHI to BoW bridge starter. Stack: Verilog, Cocotb, Icarus, Pandoc. State: `integration-bow-inject-mux`, clean.
- `pc-wsl-github-starter`: WSL + GitHub starter workflow. Stack: Python, Typer, pytest, GitHub Actions. State: `main`, clean.
- `riscv_test_asm_qemu`: RISC-V cross-compile and QEMU experiments. Stack: RISC-V GNU toolchain, QEMU. State: `master`, clean.
- `snn-crossbar-model`: Spiking neural network crossbar model. Stack: Python, PyTorch, C++, SystemC, Verilog, pytest. State: `main`, clean.
- `ucie-cxl-bridge`: UCIe to CXL bridge RTL (Phases 1–3). Stack: Verilog/SystemVerilog, Icarus, Verilator, SymbiYosys. State: `main`, clean.

## Repository notes

### `IP-axi-to-2apbs`

- Purpose: AXI to 2× APB4 bridge RTL with self-checking testbenches.
- Highlights: separate simple and burst bridge variants, APB read wait-state test sweeps (`make test-simple-ws-sweep`), and bridge design contract documented in `doc/design_contract.md`.
- Current state: clean working tree on `main`.
- Last commit: `6e5f398` — "Wire Makefile to src/test layout and add extended/parameterized TBs."

### `IP-ucie-rdi-to-pcie-pipe`

- Purpose: production-style SystemVerilog bridge from UCIe 1.0 RDI to PCIe Gen4 PIPE.
- Highlights: dual-clock CDC with Gray-code pointer synchronization, per-lane elastic FIFOs, CRC32, CDC assertion monitors, self-checking scoreboard, Verilator coverage CI job, FIFO stress verification plan, NUM_LANES=1 smoke test, and reusable IP v1.0.0 baseline tag.
- Notes: canonical RTL lives at the repo root; `src/` and `test/` subdirectories contain thin `` `include `` wrappers for EDA tools that prefer that layout. `make verilator` and `make lint` compile the root files directly.
- Current state: clean working tree on `main`; Verilator lint passes clean (`-Wall`, zero warnings).
- Last commit: `1f3a1de` — "Add NUM_LANES=1 Verilator smoke (nl1) and CI job."

### `MiT_capstone_beetle_kill`

- Purpose: PyTorch object-detection pipeline for aerial / oblique forest bark beetle survey imagery with Pascal-VOC-style XML annotations.
- Highlights: Faster R-CNN (ResNet50-FPN) training and inference, per-class precision/recall/F1 evaluation, CPU and GPU smoke tests, pytest suite, confidence-threshold tuning script, and dataset/process docs.
- Current state: clean working tree on `codex/review-improvements`; branch is ahead of `main` with automated test workflow and smoke assertion hardening.
- Last commit: `34894b5` — "Ignore local agent metadata and temporary evaluation outputs."

### `axi4_to_dfi_ddr`

- Purpose: AXI4 slave to JEDEC DFI-style bridge for a DDR PHY / memory-controller path.
- Highlights: gray-code async FIFOs for CDC, open-page SDRAM scheduler with per-bank PRE/ACT/CAS timing (`MC_T_RP`, `MC_T_RCD`, `MC_T_RAS`, `MC_T_WR`), optional refresh walk, AXI SLVERR error paths, elaboration-time parameter checks, Verilator lint, Yosys synthesis/formal hooks, generated PDF/HTML design spec, and full-functionality roadmap (`doc/FULL_FUNCTIONALITY_PLAN.md`).
- Current state: clean working tree on `main`.
- Last commit: `d98cf20` — "Checkpoint AXI response ordering and FIFO plan."

### `chi-to-bow-bridge`

- Purpose: starter CHI-to-BoW bridge that packetizes simplified CHI requests into BoW flits and reconstructs responses.
- Highlights: multiple outstanding transactions keyed by `txnid`, burst read/write support, out-of-order completion, error counters for malformed RX traffic, Cocotb verification, integration top with reference BFM, OSS Verilator structural coverage CI job, optional UVM bench (`uvm_bench/`), BoW RX inject mux with parity tests, and PDF doc build.
- Current state: clean working tree on `integration-bow-inject-mux`.
- Last commit: `312d842` — "Add BoW RX inject mux on integration top + parity tests."

### `pc-wsl-github-starter`

- Purpose: minimal starter repo for a Windows PC + WSL + GitHub workflow.
- Highlights: tiny Python app, unittest example, WSL-friendly Git config files, local `make` workflow, and a GitHub Actions CI.
- Current state: clean working tree on `main`.
- Last commit: `5283f74` — "Upgrade to Typer/Rich CLI, pytest, ruff/mypy, and venv Makefile."

### `riscv_test_asm_qemu`

- Purpose: RISC-V cross-compile and QEMU bring-up experiments covering core ISA fundamentals.
- Highlights: 10 test programs (hello, C++, exit-code, arithmetic, loops, function calls, memory load/store, bitwise ops, shifts, recursion); `make test` builds and verifies all 10 under QEMU with exact output and exit-code checks; source-interleaved disassembly targets; reorganized into `src/asm/`, `src/cpp/`, `docs/`, and `build/` layout.
- Current state: clean working tree on `master`.
- Last commit: `7d878c7` — "refactor: reorganize into src/asm, src/cpp, docs, and build/."

### `snn-crossbar-model`

- Purpose: spiking neural network targeting hardware-oriented crossbar (RRAM/PCM) design, with four-way fixed-point cross-check across Python, C++, SystemC, and Verilog RTL.
- Highlights: `snntorch`-based training with noise-aware QAT, weight-level × timestep × hidden-dim sweep, Gaussian noise robustness evaluation, bit-identical four-way cross-check (Python == C++ == SystemC == Verilog), synthesizable Verilog core (`snn_core_fixed.v`) with multi-cycle FSM and `start/done/busy` handshake, visualization tool (`scripts/visualize.py`), and 38-test pytest suite.
- Current state: clean working tree on `main`.
- Last commit: `cb14e44` — "Add development roadmap."

### `ucie-cxl-bridge`

- Purpose: experimental UCIe Adapter Layer to CXL.io / CXL.cache / CXL.mem bridge.
- Highlights: three completed phases — Phase 1 typed 64-bit packet model and CXL.io <-> UCIe translation; Phase 2 full packet taxonomy (CXL.io / CXL.mem / CXL.cache requests and AD_CPL / MEM_CPL / CACHE_CPL completions) with XOR checksum and GTKWave save file; Phase 3 per-direction credit counters (`credit_counter.v`), posted/non-posted ordering domain split with posted-priority egress arbiter and registered arbiter lock for valid/ready stability, ordering directed test, and SymbiYosys BMC + cover on both `sync_fifo` and `cxl_ucie_bridge`. Verilator lint clean, Windows PowerShell sim helper included. Design spec updated for Phase 3.
- Current state: clean working tree on `main`.
- Last commit: `78a3d56` — "docs: update design-spec for Phase 3 (credit/ordering, arbiter lock)."

## Overall observations

- Eight of the nine repositories are hardware / verification projects (RTL bridges, CDC, memory controllers, a protocol bridge, and a spiking neural network with RTL cross-check).
- `MiT_capstone_beetle_kill` is the sole ML/Python project.
- `chi-to-bow-bridge` and `MiT_capstone_beetle_kill` are on active feature branches (`integration-bow-inject-mux` and `codex/review-improvements` respectively); all other repos are on `main` / `master`.
- All 9 repositories currently have clean working trees.
