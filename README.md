# Project Repositories Summary

**Snapshot dates** here (the **inspected on** line, maintenance section headings, and **Verification stamp**) use **this workstation's local calendar day** — i.e. what `date` reports under your current **`TZ`** / system clock — **not** UTC, unless a note says otherwise.

This directory contains 9 Git repositories. The notes below reflect each repo's local `README.md`, top-level files, and Git status as inspected on **2026-05-06**.

## 2026-05-06 maintenance update

- Re-surveyed all nine sub-repos for newest commits, branch alignment, and working-tree noise.
- **Verification stamp:** on **2026-05-06**, each clone matches **`origin`** (**ahead 0 / behind 0** after **`git fetch`**) and local dirt matches the **Repository notes** section (`NOTES`, generated UVM PDF) where called out.
- **`chi-to-bow-bridge`**: merged PR #19 — shared Pandoc defaults (**XeLaTeX** + **DejaVu** fonts), Makefiles use **`--defaults`** with **`docs/pandoc-pdf-defaults.yaml`** for design/integration/UVM/Verilator README PDFs; UVM Markdown reflow for PDF-safe layout (`docs/pandoc-pdf.md`). Repo remains Cocotb + Icarus core with **`vlate_bench/`** Verilator parity TB and optional **`uvm_bench/`** VCS/UVM.
- **`IP-axi-to-2apbs`**: documentation refresh — UVM README maps, PDF-friendly trees, **`readme-md-pdfs`** Make target.
- **`IP-ucie-rdi-to-pcie-pipe`**: UVM documentation PDF formatting polish; working tree still has **untracked** `NOTES` and `test/uvm/UVM_README.pdf`.
- **`axi4_to_dfi_ddr`**: added **UVM DV environment for VCS**; working tree has **untracked** `NOTES`.
- **`snn-crossbar-model`**: working tree has **untracked** `NOTES` (last tracked commit unchanged since roadmap add).
- **`ucie-cxl-bridge`**: cleanup of tracked tool artifacts and `.gitignore` refresh.

Prior sweep (**2026-05-02**) covered Verilator coverage on UCIe IP, AXI/DDR checkpoints, RISC-V layout refactor, SNN visualization/roadmap, CXL Phase 3 doc updates, AXI-2APBS Makefile wiring, and **`pc-wsl-github-starter`** CLI/tooling upgrades — details remain accurate where commits below did not move.

## At a glance

- `IP-axi-to-2apbs`: AXI to dual-APB4 bridge RTL. Stack: Verilog, Icarus. State: `main`, clean.
- `IP-ucie-rdi-to-pcie-pipe`: UCIe RDI to PCIe PIPE bridge RTL. Stack: SystemVerilog, Verilator, vendor simulators. State: `main`, clean except untracked notes/PDF (see notes).
- `MiT_capstone_beetle_kill`: Forest bark beetle object detection. Stack: Python, PyTorch, pytest. State: `main`, clean.
- `axi4_to_dfi_ddr`: AXI4 to DFI / DDR bridge RTL. Stack: Verilog, Icarus, Verilator, Yosys, Pandoc, optional VCS/UVM DV. State: `main`, clean except untracked `NOTES`.
- `chi-to-bow-bridge`: CHI to BoW bridge starter. Stack: Verilog, Cocotb, Icarus, integration + **`vlate_bench`** Verilator TB, optional **`uvm_bench`** VCS/UVM, Pandoc/XeLaTeX PDFs. State: `main`, clean.
- `pc-wsl-github-starter`: WSL + GitHub starter workflow. Stack: Python, Typer, pytest, GitHub Actions. State: `main`, clean.
- `riscv_test_asm_qemu`: RISC-V cross-compile and QEMU experiments. Stack: RISC-V GNU toolchain, QEMU. State: `master`, clean.
- `snn-crossbar-model`: Spiking neural network crossbar model. Stack: Python, PyTorch, C++, SystemC, Verilog, pytest. State: `main`, clean except untracked `NOTES`.
- `ucie-cxl-bridge`: UCIe to CXL bridge RTL (Phases 1–3). Stack: Verilog/SystemVerilog, Icarus, Verilator, SymbiYosys. State: `main`, clean.

## Repository notes

### `IP-axi-to-2apbs`

- Purpose: AXI to 2× APB4 bridge RTL with self-checking testbenches.
- Highlights: separate simple and burst bridge variants, APB read wait-state test sweeps (`make test-simple-ws-sweep`), bridge design contract in `doc/design_contract.md`, UVM README maps / PDF-oriented trees, **`readme-md-pdfs`** Make target.
- Current state: clean working tree on `main`.
- Last commit: `2d985b6` — "docs: UVM README maps, PDF-friendly trees, readme-md-pdfs target".

### `IP-ucie-rdi-to-pcie-pipe`

- Purpose: production-style SystemVerilog bridge from UCIe 1.0 RDI to PCIe Gen4 PIPE.
- Highlights: dual-clock CDC with Gray-code pointer synchronization, per-lane elastic FIFOs, CRC32, CDC assertion monitors, self-checking scoreboard, Verilator coverage CI, FIFO stress verification plan, NUM_LANES=1 smoke test, reusable IP v1.0.0 baseline tag, enhanced UVM docs + PDF formatting.
- Notes: canonical RTL lives at the repo root; `src/` and `test/` subdirectories contain thin `` `include `` wrappers for EDA tools that prefer that layout. `make verilator` and `make lint` compile the root files directly.
- Current state: `main` aligned with `origin/main`; **untracked** `NOTES` and `test/uvm/UVM_README.pdf` present locally.
- Last commit: `213dd0e` — "Enhance UVM documentation with professional PDF formatting".

### `MiT_capstone_beetle_kill`

- Purpose: PyTorch object-detection pipeline for aerial / oblique forest bark beetle survey imagery with Pascal-VOC-style XML annotations.
- Highlights: Faster R-CNN (ResNet50-FPN) training and inference, per-class precision/recall/F1 evaluation, CPU and GPU smoke tests, pytest suite, confidence-threshold tuning script, and dataset/process docs.
- Current state: clean working tree on `main`; PR #1 merged — automated test workflow, smoke assertion hardening, and agent metadata cleanup now on main.
- Last commit: `f44c5fa` — "Merge pull request #1: Improve detector robustness, test workflow, and agent metadata cleanup."

### `axi4_to_dfi_ddr`

- Purpose: AXI4 slave to JEDEC DFI-style bridge for a DDR PHY / memory-controller path.
- Highlights: gray-code async FIFOs for CDC, open-page SDRAM scheduler with per-bank PRE/ACT/CAS timing (`MC_T_RP`, `MC_T_RCD`, `MC_T_RAS`, `MC_T_WR`), optional refresh walk, AXI SLVERR error paths, elaboration-time parameter checks, Verilator lint, Yosys synthesis/formal hooks, generated PDF/HTML design spec, full-functionality roadmap (`doc/FULL_FUNCTIONALITY_PLAN.md`), **UVM DV environment for VCS**.
- Current state: `main` aligned with `origin/main`; **untracked** `NOTES` locally.
- Last commit: `e671df3` — "feat(uvm_dv): add UVM DV environment for VCS".

### `chi-to-bow-bridge`

- Purpose: starter CHI-to-BoW bridge that packetizes simplified CHI requests into BoW flits and reconstructs responses.
- Highlights: Cocotb + Icarus unit/integration flows; integration top with reference BFM; OSS **`vlate_bench/`** Verilator + C++ parity TB (lint/run/coverage hooks); optional **`uvm_bench/`** Synopsys VCS / UVM bench with onboarding/quickref PDFs; integration protocol checker bind coverage across flows; BoW RX inject path + unknown-txn **`RSP_HDR`** parity; OSS regression Makefile targets; Markdown→PDF via Pandoc **XeLaTeX** + **DejaVu** (`docs/pandoc-pdf-defaults.yaml`, `docs/pandoc-pdf-header.tex`).
- Current state: clean working tree on `main`.
- Last commit: `00c0230` — "Merge pull request #19 from markrthomas/chore/pdf-pandoc-xelatex-dejavu".

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
- Current state: `main` aligned with `origin/main`; **untracked** `NOTES` locally.
- Last commit: `cb14e44` — "Add development roadmap."

### `ucie-cxl-bridge`

- Purpose: experimental UCIe Adapter Layer to CXL.io / CXL.cache / CXL.mem bridge.
- Highlights: three completed phases — Phase 1 typed 64-bit packet model and CXL.io <-> UCIe translation; Phase 2 full packet taxonomy (CXL.io / CXL.mem / CXL.cache requests and AD_CPL / MEM_CPL / CACHE_CPL completions) with XOR checksum and GTKWave save file; Phase 3 per-direction credit counters (`credit_counter.v`), posted/non-posted ordering domain split with posted-priority egress arbiter and registered arbiter lock for valid/ready stability, ordering directed test, and SymbiYosys BMC + cover on both `sync_fifo` and `cxl_ucie_bridge`. Verilator lint clean, Windows PowerShell sim helper included.
- Current state: clean working tree on `main`.
- Last commit: `12b04a6` — "Clean up tracked tool artifacts and update .gitignore".

## Overall observations

- Eight of the nine repositories are hardware / verification projects (RTL bridges, CDC, memory controllers, a protocol bridge, and a spiking neural network with RTL cross-check).
- `MiT_capstone_beetle_kill` is the sole ML/Python project.
- All nine repositories track **`main`** / **`master`** in lockstep with their remotes; several clones carry **untracked** scratch (`NOTES`) or generated UVM PDFs as noted above.
- **Workspace PDF**: this summary's **`make pdf`** uses the same **XeLaTeX + DejaVu** stack as **`chi-to-bow-bridge`** (`.pandoc-pdf-defaults.yaml` + `.pandoc-header.tex`).
