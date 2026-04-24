# Project Repositories Summary

This directory contains 9 Git repositories. The notes below reflect each repo's local `README.md`, top-level files, and Git status as inspected on 2026-04-24.

## 2026-04-24 maintenance update

- Surveyed and tested all 9 sub-repos.
- Fixed Verilator lint warnings (width mismatches, unused signal) in `IP-ucie-rdi-to-pcie-pipe` RTL.
- Fixed `make verilator` CI failure in `IP-ucie-rdi-to-pcie-pipe` (Makefile now uses root `.sv` files directly rather than `src/`/`test/` include-wrappers that Verilator could not resolve).
- Added typed 64-bit packet model (CXL.io ↔ UCIe translation, checksum, error packets) to `ucie-cxl-bridge`.
- Updated documentation across all repos: filled in `ucie-cxl-bridge` Architecture section, expanded `riscv_test_asm_qemu` README to cover all 10 ISA tests, corrected `IP-ucie-rdi-to-pcie-pipe` project structure description.
- All 9 sub-repos are clean on their respective branches.

## At a glance

- `IP-axi-to-2apbs`: AXI to dual-APB4 bridge RTL. Stack: Verilog, Icarus. State: `main`, clean.
- `IP-ucie-rdi-to-pcie-pipe`: UCIe RDI to PCIe PIPE bridge RTL. Stack: SystemVerilog, Verilator, vendor simulators. State: `main`, clean.
- `MiT_capstone_beetle_kill`: Forest bark beetle object detection. Stack: Python, PyTorch, pytest. State: `codex/review-improvements`, clean.
- `axi4_to_dfi_ddr`: AXI4 to DFI / DDR bridge RTL. Stack: Verilog, Icarus, Verilator, Yosys, Pandoc. State: `main`, clean.
- `chi-to-bow-bridge`: CHI to BoW bridge starter. Stack: Verilog, Cocotb, Icarus, Pandoc. State: `codex/bridge-hardening-fixes`, clean.
- `pc-wsl-github-starter`: WSL + GitHub starter workflow. Stack: Python, unittest, GitHub Actions. State: `main`, clean.
- `riscv_test_asm_qemu`: RISC-V cross-compile and QEMU experiments. Stack: RISC-V GNU toolchain, QEMU. State: `master`, clean.
- `snn-crossbar-model`: Spiking neural network crossbar model. Stack: Python, PyTorch, C++, SystemC, Verilog, pytest. State: `main`, clean.
- `ucie-cxl-bridge`: UCIe to CXL bridge RTL. Stack: Verilog/SystemVerilog, Icarus, Verilator, formal. State: `main`, clean.

## Repository notes

### `IP-axi-to-2apbs`

- Purpose: AXI to 2× APB4 bridge RTL with self-checking testbenches.
- Highlights: separate simple and burst bridge variants, plus APB read wait-state test sweeps (`make test-simple-ws-sweep`).
- Current state: clean working tree on `main`.
- Last commit: `be91f10` — "Standardize repository layout with src/test/doc directories."

### `IP-ucie-rdi-to-pcie-pipe`

- Purpose: production-style SystemVerilog bridge from UCIe 1.0 RDI to PCIe Gen4 PIPE.
- Highlights: dual-clock CDC with Gray-code pointer synchronization, per-lane elastic FIFOs, CRC32, CDC assertion monitors, and Verilator simulation flow with GitHub Actions CI.
- Notes: canonical RTL lives at the repo root; `src/` and `test/` subdirectories contain thin `` `include `` wrappers for EDA tools that prefer that layout. `make verilator` and `make lint` compile the root files directly.
- Current state: clean working tree on `main`; Verilator lint passes clean (`-Wall`, zero warnings) after fixing width-unsafe pointer arithmetic and removing an unused signal.
- Last commit: `fecfb64` — "docs: correct Project Structure — root files are canonical RTL."

### `MiT_capstone_beetle_kill`

- Purpose: PyTorch object-detection pipeline for aerial / oblique forest bark beetle survey imagery with Pascal-VOC-style XML annotations.
- Highlights: Faster R-CNN (ResNet50-FPN) training and inference, per-class precision/recall/F1 evaluation, CPU and GPU smoke tests, pytest suite, confidence-threshold tuning script, and dataset/process docs.
- Current state: clean working tree on `codex/review-improvements`; branch is ahead of `main` with automated test workflow and smoke assertion hardening.
- Last commit: `34894b5` — "Ignore local agent metadata and temporary evaluation outputs."

### `axi4_to_dfi_ddr`

- Purpose: AXI4 slave to JEDEC DFI-style bridge for a DDR PHY / memory-controller path.
- Highlights: gray-code async FIFOs for CDC, open-page SDRAM scheduler with per-bank PRE/ACT/CAS timing (`MC_T_RP`, `MC_T_RCD`, `MC_T_RAS`, `MC_T_WR`), optional refresh walk, AXI SLVERR error paths, elaboration-time parameter checks, Verilator lint, Yosys synthesis/formal hooks, and generated PDF/HTML design spec.
- Current state: clean working tree on `main`.
- Last commit: `187f4ab` — "Harden CI rebuilds and Icarus compatibility."

### `chi-to-bow-bridge`

- Purpose: starter CHI-to-BoW bridge that packetizes simplified CHI requests into BoW flits and reconstructs responses.
- Highlights: multiple outstanding transactions keyed by `txnid`, burst read/write support, out-of-order completion, error counters for malformed RX traffic, Cocotb verification (9 tests), integration top with reference BFM, and PDF doc build.
- Current state: clean working tree on `codex/bridge-hardening-fixes`; PR #4 open against `main`.
- Last commit: `add4f1d` — "Add integration top and BFM, docs, and consolidated CI."

### `pc-wsl-github-starter`

- Purpose: minimal starter repo for a Windows PC + WSL + GitHub workflow.
- Highlights: tiny Python app, unittest example, WSL-friendly Git config files, local `make` workflow, and a GitHub Actions CI.
- Current state: clean working tree on `main`.
- Last commit: `c7c6273` — "Improve local automation docs and ignore local agent state."

### `riscv_test_asm_qemu`

- Purpose: RISC-V cross-compile and QEMU bring-up experiments covering core ISA fundamentals.
- Highlights: 10 test programs (hello, C++, exit-code, arithmetic, loops, function calls, memory load/store, bitwise ops, shifts, recursion); `make test` builds and verifies all 10 under QEMU with exact output and exit-code checks; disassembly targets including source-interleaved output.
- Current state: clean working tree on `master`.
- Last commit: `8ab9ee1` — "docs: document all ten ISA test programs in README."

### `snn-crossbar-model`

- Purpose: spiking neural network targeting hardware-oriented crossbar (RRAM/PCM) design, with four-way fixed-point cross-check across Python, C++, SystemC, and Verilog RTL.
- Highlights: `snntorch`-based training with noise-aware QAT, weight-level × timestep × hidden-dim sweep, Gaussian noise robustness evaluation, bit-identical four-way cross-check (Python == C++ == SystemC == Verilog), synthesizable Verilog core (`snn_core_fixed.v`) with multi-cycle FSM and `start/done/busy` handshake, and 38-test pytest suite.
- Current state: clean working tree on `main`.
- Last commit: `3878acc` — "Add multi-cycle SNN core FSM, handshake, busy, and aligned SystemC."

### `ucie-cxl-bridge`

- Purpose: experimental UCIe Adapter Layer to CXL.io / CXL.cache / CXL.mem bridge.
- Highlights: Phase 1 typed-packet model with 64-bit packet definitions (`cxl_ucie_bridge_defs.vh`), CXL.io request → UCIe adapter request translation, UCIe completion → CXL.io completion translation, XOR checksum generation and verification, explicit error/invalid packet output for unsupported kinds, bounded formal (BMC + cover) on `sync_fifo`, Verilator lint, and Windows PowerShell sim helper.
- Current state: clean working tree on `main`.
- Last commit: `79f2a63` — "docs: fill in Architecture section with typed-packet model description."

## Overall observations

- Eight of the nine repositories are hardware / verification projects (RTL bridges, CDC, memory controllers, a protocol bridge, and a spiking neural network with RTL cross-check).
- `MiT_capstone_beetle_kill` is the sole ML/Python project.
- `chi-to-bow-bridge` and `MiT_capstone_beetle_kill` are on active feature branches (`codex/bridge-hardening-fixes` and `codex/review-improvements` respectively); all other repos are on `main` / `master`.
- All 9 repositories currently have clean working trees.
