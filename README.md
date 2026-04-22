# Project Repositories Summary

This directory contains 8 Git repositories. The notes below are based on each repo's local `README.md`, top-level files, and current Git status as inspected on 2026-04-22.

## 2026-04-22 maintenance update

- Checked and tested all repos that had non-clean working trees.
- Fixed repository hygiene issues by adding/expanding `.gitignore` rules where needed.
- Committed and pushed updates in:
  - `IP-ucie-rdi-to-pcie-pipe` (`9d44b0d`)
  - `MiT_capstone_beetle_kill` (`34894b5`)
  - `pc-wsl-github-starter` (`c7c6273`)
- Current result: all sub-repositories are clean.

## At a glance

- `IP-ucie-rdi-to-pcie-pipe`: UCIe RDI to PCIe PIPE bridge RTL. Stack: SystemVerilog, Verilator, vendor simulators. State: `main`, clean.
- `ucie-cxl-bridge`: UCIe to CXL bridge RTL. Stack: Verilog/SystemVerilog, Icarus, Verilator, formal. State: `main`, clean.
- `IP-axi-to-2apbs`: AXI to dual-APB4 bridge RTL. Stack: Verilog, Icarus. State: `main`, clean.
- `chi-to-bow-bridge`: CHI to BoW bridge starter. Stack: Verilog, Cocotb, Icarus, Pandoc. State: `codex/bridge-hardening-fixes`, clean.
- `axi4_to_dfi_ddr`: AXI4 to DFI / DDR bridge RTL. Stack: Verilog, Icarus, Verilator, Yosys, Pandoc. State: `main`, clean.
- `riscv_test_asm_qemu`: RISC-V cross-compile and QEMU experiments. Stack: RISC-V GNU toolchain, QEMU. State: `master`, clean.
- `MiT_capstone_beetle_kill`: Forest bark beetle object detection. Stack: Python, PyTorch, pytest. State: `codex/review-improvements`, clean.
- `pc-wsl-github-starter`: WSL + GitHub starter workflow. Stack: Python, unittest, GitHub Actions. State: `main`, clean.

## Repository notes

### `IP-ucie-rdi-to-pcie-pipe`

- Purpose: production-style SystemVerilog bridge from UCIe 1.0 RDI to PCIe Gen4 PIPE.
- Highlights: dual-clock CDC handling, per-lane elastic FIFOs, CRC32 support, assertions, and Verilator-oriented simulation flow.
- Current state: clean working tree on `main`; Verilator flow and CI assets refreshed.
- Last commit: `9d44b0d` on 2026-04-22, "Stabilize UCIe-to-PIPE simulation assets and CI coverage."

### `ucie-cxl-bridge`

- Purpose: experimental UCIe Adapter Layer to CXL.io / CXL.cache / CXL.mem bridge.
- Highlights: baseline dual-FIFO streaming shell, simulation CI, optional Verilator lint, and bounded formal checks on `sync_fifo`.
- Current state: clean working tree on `main`.
- Last commit: `a33af7b` on 2026-04-13, improving CI formal path handling.

### `IP-axi-to-2apbs`

- Purpose: AXI to 2x APB4 bridge RTL with self-checking testbenches.
- Highlights: separate simple and burst bridge variants, plus APB read wait-state test sweeps through `make`.
- Current state: clean working tree on `main`.
- Last commit: `0cc3a3c` on 2026-04-20, fixing APB timing and simulation flow.

### `chi-to-bow-bridge`

- Purpose: starter CHI-to-BoW bridge that packetizes simplified CHI requests into BoW flits and reconstructs responses.
- Highlights: Cocotb-based verification, documentation build flow, waveform generation, and protocol guardrails for invalid response patterns.
- Current state: clean working tree on `codex/bridge-hardening-fixes`.
- Last commit: `1fad8a4` on 2026-04-21, adding burst coverage and design-spec updates.

### `axi4_to_dfi_ddr`

- Purpose: AXI4 slave to JEDEC DFI-style bridge for a DDR PHY / memory-controller path.
- Highlights: async FIFOs for CDC, open-page scheduling, parameterized timing, smoke tests, elaboration-fail checks, optional Verilator lint, Yosys synthesis/formal hooks, and generated design docs.
- Current state: clean working tree on `main`.
- Last commit: `ae3401f` on 2026-04-12, adding elaboration guards for MC timing and DFI init cycles.

### `riscv_test_asm_qemu`

- Purpose: small RISC-V bring-up / learning repo for assembling, compiling, running, and disassembling simple programs under QEMU.
- Highlights: Make targets for assembly and C++, targeted objdump outputs (`_start`, `main`, source-interleaved `main`), and simple output-based tests.
- Contents: `hello.s`, `howdy.cpp`, generated binaries/objects, and a Makefile; there is no repo README yet.
- Current state: clean working tree on `master`.
- Last commit: `438e894` on 2026-04-06, adding source-interleaved main disassembly.

### `MiT_capstone_beetle_kill`

- Purpose: PyTorch object-detection pipeline for aerial / oblique forest bark beetle survey imagery with Pascal-VOC-style XML annotations.
- Highlights: Faster R-CNN training, inference, evaluation metrics, smoke tests, pytest-based tests, threshold tuning scripts, and dataset/process docs.
- Current state: clean working tree on `codex/review-improvements`.
- Last commit: `34894b5` on 2026-04-22, "Ignore local agent metadata and temporary evaluation outputs."

### `pc-wsl-github-starter`

- Purpose: minimal starter repo for a Windows PC + WSL + GitHub workflow.
- Highlights: tiny Python app, unittest example, WSL-friendly Git config files, and a GitHub Actions workflow.
- Current state: clean working tree on `main`.
- Last commit: `c7c6273` on 2026-04-22, "Improve local automation docs and ignore local agent state."

## Overall observations

- Most repositories in this directory are hardware / verification projects focused on RTL bridges and CDC-heavy interfaces.
- `MiT_capstone_beetle_kill` is the main non-RTL project; it is a Python/PyTorch ML pipeline.
- All repositories currently have clean working trees.
- `riscv_test_asm_qemu` is the only repo here without its own README, so this top-level summary is the main written orientation for it right now.
