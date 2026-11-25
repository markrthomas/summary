# DESIGN_READINESS.md — Tapeout-readiness program for the 5 design-track IP blocks

**As of:** 2026-11-23 · Owner: Mark Thomas · Status: **program kickoff**

This is the workspace-level plan that takes five repos from *functionally complete,
OSS-verified IP* to **tapeout sign-off** (full path to silicon). It defines the common
readiness bar (the T-gates), the tooling/PDK reality, the sequencing, and a cross-repo
status matrix. Each repo carries its own tailored plan that maps its work onto these
gates — see the per-repo plan file linked in the matrix.

> Companion documents: [`DV_STANDARDS.md`](DV_STANDARDS.md) (the DV gate every repo already
> meets) and each repo's own plan. This file governs everything *above* the DV gate — the
> synthesis, timing, low-power, DFT, gate-level and packaging sign-offs that DV_STANDARDS
> deliberately does not cover.

---

## 1. Why these five

They were selected as the blocks most likely to appear in a real chip: standard,
wire-realistic interfaces, a genuine SoC need, and existing design maturity. The rest of
the workspace is deliberately excluded — the `*-on-*` bridges use invented or
non-wire-accurate protocol abstractions, and the `apb-to-mem-*` / `uvm_review` trio are
teaching derivatives. See the repo catalog `README.md` for the full reasoning.

| # | Repo | Block | Standards | Per-repo plan |
|---|------|-------|-----------|---------------|
| 5 | `ucie_rdi_to_pcie6_pipe7` | UCIe 1.0 RDI ↔ PCIe 6.x / PIPE 7.1 MAC (Gen5/Gen6) | **UCIe (public), PCIe base + PIPE 7.1 (NON-PUBLIC)** | [`PLAN.md`](ucie_rdi_to_pcie6_pipe7/PLAN.md) |
| 1 | `axi4_to_dfi_ddr` | AXI4 → DFI/DDR memory-controller path | AXI4 (public), DFI (public), DDR/JEDEC (reg-gated) | [`doc/FULL_FUNCTIONALITY_PLAN.md`](axi4_to_dfi_ddr/doc/FULL_FUNCTIONALITY_PLAN.md) |
| 2 | `tilelink_to_AXI4` | TL-UH/UL/C → AXI4 / AXI4-Lite / CHI bridges (Chisel) | TileLink (public), AXI4 (public), CHI (public) | [`doc/PLAN.md`](tilelink_to_AXI4/doc/PLAN.md) |
| 3 | `IP-axi-to-2apbs` | AXI → dual-APB4 peripheral bridge | AXI4, APB4 (public) | [`doc/PLAN.md`](IP-axi-to-2apbs/doc/PLAN.md) |
| 4 | `cxl_lpddr5x_bridge` | CXL.mem → LPDDR5X memory-side bridge | CXL (reg-gated), LPDDR5X/JEDEC (reg-gated) | [`doc/PLAN.md`](cxl_lpddr5x_bridge/doc/PLAN.md) |

---

## 2. The readiness bar — T-gates (common to all five)

Every block signs off the same eight gates. DV_STANDARDS (`lint/sim/regress/coverage/
formal/ci`) is the entry criterion to **T5**, not the finish line. A gate is passed only
with a **real artifact** (the workspace doctrine: *no artifact = not verified*); an
authored-but-not-run deliverable (today's UVM and UPF) is **T-pending**, not passed.

| Gate | Name | Pass criteria (artifact) |
|------|------|--------------------------|
| **T0** | Spec freeze & provenance | Wire-accurate, frozen interface + CSR map; every encoding traced to a cited spec clause; non-public spec constants sourced under license and kept in a private repo; export-control / licensing note. |
| **T1** | Synthesizable RTL sign-off | Real logic synthesis to a target library: zero inferred latches, defined memory strategy (compiled RAM vs flop array), synth-lint / CDC / RDC structurally clean on a sign-off ruleset (Spyglass-class), reset architecture documented. |
| **T2** | Constraints & STA | Complete SDC (clock defs, I/O budgets, async/CDC + false/multicycle exceptions); setup+hold STA clean at PVT corners; Fmax per clock domain vs target. |
| **T3** | Low-power sign-off | UPF validated on **power-aware simulation + synthesis** (isolation, level-shifters, retention, power-switch); power-state table; UPF↔UPF and RTL↔UPF logical-equivalence check. |
| **T4** | DFT sign-off | Scan inserted; ATPG stuck-at ≥99% / transition ≥90% (or documented target); MBIST for every RAM; DFT constraints; chip-level boundary scan where applicable. |
| **T5** | Functional verification sign-off | UVM run on a **licensed simulator**; documented coverage model; code + functional + assertion coverage closed with signed-off exclusions; constrained-random + soak; green regression gate; bug-rate trended to zero. |
| **T6** | Gate-level & PPA | Gate-level sim with back-annotated SDF; vector + vectorless power; RTL↔netlist logical equivalence (LEC); PPA report vs area/power/timing targets. |
| **T7** | Integration & packaging | IP-XACT (or equivalent) package; address map + register abstraction (RAL) consistent with RTL; clock/reset/power connectivity + integration guide; parameter/config matrix validated; deliverable manifest; versioned release tag. |

**Sign-off checklist** (one per repo, lives in `syn/SIGNOFF.md` once the flow lands):
each T-gate → artifact path → pass date → reviewer.

---

## 3. Tooling & PDK reality (read before committing a schedule)

This workspace is **OSS-only today** (Verilator, Icarus, Yosys, SymbiYosys, cocotb/PyUVM).
That stack can take every block through DV and can **pathfind** T1/T2/T6 on an open PDK, but
real tapeout sign-off needs tools and data this environment does not have:

- **Open pathfinder (available / low-cost):** Yosys + OpenLane/OpenROAD on **sky130** or
  **gf180mcu**. Good enough to shake out synthesizability, gross timing, area, and a real
  P&R + GDS for the *small* blocks. **Not** representative for Gen6/PAM4, LPDDR5X or UCIe
  signalling — those need an advanced node.
- **Sign-off (requires licenses + NDA data):** Synopsys DC/Fusion Compiler or Cadence
  Genus/Innovus; PrimeTime (STA); VC-LP/UPF + Conformal/Formality (LEC); Tessent/DFTMAX +
  ATPG; VCS or Xcelium (the authored UVM/UPF); Spyglass (lint/CDC/RDC). Plus a **foundry
  PDK + memory compilers + standard-cell libraries under NDA**, and for #5/#4 the
  controlled interface specs.
- **Consequence for #5:** advanced-node + UCIe + controlled PIPE/PCIe spec = the most
  NDA-gated path. Doing its T0 (real spec-accurate encodings) is now *legal in the private
  repo*; doing its T1–T6 on real silicon data is gated on foundry/EDA access. Where that
  access is absent, the deliverable is the **sign-off-ready collateral** (SDC, UPF, DFT
  intent, constraints, flow scripts, coverage model) that a team with the licenses runs —
  and that is an honest, valuable finish line to declare per block.

Every per-repo plan therefore marks each item **[oss-pathfind]** (doable here) or
**[needs-license]** / **[needs-pdk]** (collateral authored here, run elsewhere). We do not
claim a gate passed on a tool we did not run.

---

## 4. Shared sign-off flow (build once, roll across repos)

The T-gate flows are ~80% identical across blocks. Build them **once** as a reusable kit
and parameterize per repo, rather than five hand-rolled flows:

- `syn/` — synthesis scripts (OSS: Yosys+OpenLane; stub hooks for DC/Genus), per-repo
  `constraints/*.sdc`, `SIGNOFF.md` checklist.
- `sta/` — STA setup (OpenSTA pathfinder; PrimeTime hooks).
- `lp/` — UPF + power-state table + power-aware TB wiring (several repos already have an
  authored `lp/`; standardize it).
- `dft/` — scan/ATPG/MBIST intent + constraints (collateral; vendor ATPG runs elsewhere).
- `pkg/` — IP-XACT/packaging, register-map source of truth + RAL generation.

Home for the kit: extend **`dv-swarm-kit`** (already synced into every repo) with a
`signoff/` module, or a sibling `design-signoff-kit`. Decide at program kickoff; the
per-repo plans assume the kit exists and reference `syn/`, `sta/`, `dft/`, `lp/`, `pkg/`.

---

## 5. Sequencing

1. **#5 `ucie_rdi_to_pcie6_pipe7` → PRIVATE — DONE (2026-11-23).** Flipped to private so the
   controlled PIPE 7.1 / PCIe 6.x spec work (T0) can proceed without publishing controlled
   material. It is the lead/priority IP.
2. **#5 leads on T0** — convert the "illustrative-but-flagged" PIPE §7 register/encoding
   fidelity into real spec-accurate encodings (its already-scoped Phase J, items 51–54),
   under license, in the private repo. This is the long-lead, access-gated item; start it first.
3. **Pathfind the shared sign-off flow on #3 `IP-axi-to-2apbs` in parallel** (recommended):
   it is the smallest, cleanest, single-clock-domain block (100% coverage, UVM-on-Verilator
   green, formal safety+liveness). It is the cheapest vehicle to stand up `syn/sta/dft/lp/pkg`
   on the open PDK and prove the kit before rolling it onto the harder blocks. **This is a
   recommendation — #5 remains the priority; #3 de-risks the flow so #5 isn't building it from
   scratch.**
4. **Then roll the kit across #4, #2, #1**, hardest-RTL-last: `axi4_to_dfi_ddr` (#1) needs the
   most RTL completion before it can even enter T1, so it finishes the sequence.
5. Each block privatizes **before** its T0 spec work if (and only if) it depends on controlled
   material. #5 already did; #4 (LPDDR5X/CXL) and #1 (JEDEC DDR) use registration-gated-but-free
   specs, so they can stay public unless a specific JEDEC clause needs reproducing verbatim.

---

## 6. Cross-repo status & gap matrix

Legend: ✅ passed (artifact) · ◑ authored-not-run (T-pending) · ◐ partial / in-progress · ☐ not started · n/a.

| Gate | #5 ucie→pipe7 | #1 axi4→dfi | #2 tl→axi4 | #3 axi→2apb | #4 cxl→lpddr5x |
|------|:---:|:---:|:---:|:---:|:---:|
| DV gate (entry) | ✅ | ✅ | ✅ | ✅ | ✅ |
| **T0** spec freeze | ◐ (Phase J to real encodings; **private**) | ◐ (DFI single-phase; JEDEC subset) | ◐ (TLCToCHI 1/7) | ✅ (public, frozen) | ◐ ("LPDDR5X-style", not real PHY) |
| **T1** synth | ✅ `make synth` 22629 cells/0 latch (slang) + ✅ multiclock formal CDC (`make formal`, CI) | ✅ `make synth` 13090 cells/0 latch + ✅ `make cdc` | ✅ `make syn` (gen-SV, 3 tops) | ✅ `make syn` (latch-free) | ✅ `make synth` + ✅ `make cdc` |
| **T2** STA | ◑ SDC+STA (needs-pdk) | ◑ SDC+STA | ◑ SDC+STA | ◑ SDC+STA | ◑ SDC+STA |
| **T3** low-power | ◑ authored UPF + P0→P2 test | ◐ UPF + OSS lint (`make lp`) | ◐ single-domain UPF + lint (`make lp`) | ◐ UPF + OSS lint (`make lp`) | ◐ UPF + OSS lint (`make lp`) |
| **T4** DFT | ◐ scan-ready (`make dft`) | ◐ scan-ready (`make dft`) | ◐ scan-ready (`make dft`) | ◐ scan-ready (`make dft`) | ◐ scan-ready (`make dft`) |
| **T5** verif sign-off | ◑ UVM/VCS authored; 98.3% line + 100% fcov on OSS | ◐ directed+FIFO BMC | ◐ 95.1% + formal | ◑ UVM-on-Vl green; 100% line; formal S+L | ◑ 100% line; unbounded formal prove; UVM authored |
| **T6** GLS + PPA | ☐ (slang; Actions-quota) | ◐ `make gls`+`make ppa` (chparam override) | ◐ `make ppa` (3 tops); GLS=Verilator recipe | ◐ `make gls`+`make ppa` (pathfind) | ◐ `make ppa`; GLS needs-pdk (dual-clk RAM X) |
| **T7** integration/pkg | ☐ | ◐ IP-XACT+guide, `make pkg` (71/71) | ◐ IP-XACT+guide, `make pkg` (53/36/68) | ◐ IP-XACT+guide, `make pkg` (pathfind) | ◐ IP-XACT+guide, `make pkg` (22/22) |

(◑ = authored-not-run; ◐ = partial/in-progress; ◑ and ◐ both read as **T-pending**.)

The headline (updated 2026-11-25): **T1 now has a runnable OSS synth gate passing on all
five** (`make synth`/`make syn`, latch-free + cell/depth artifacts, in CI; structural
`make cdc` on the multi-clock #1/#4, and a multiclock **formal** CDC proof — on the real
elastic buffer, independent wr/rd clocks — now CI-gated on #5), and **T2 SDC + STA drivers are authored on all five**
(run is `needs-pdk`). #5's earlier "not a valid top-level module" turned out to be a
gate quoting bug (a newline-separated `$(ls …)` file list split the yosys `-p` script),
not an RTL or slang-version problem; fixed, and the full top synthesizes (22629 cells,
latch-free). **T3/T4 are now rolled out to all five** (`make lp` UPF-consistency lint +
`make dft` scan-readiness audit, both OSS and in CI; the `-upf` sim, scan insertion and
ATPG stay needs-license): T4 scan-readiness PASSES on all five (latch-free + no comb loops,
with per-block flop/reset/async/RAM inventories — #5 6766 flops via slang, #1 2924, #4 1557,
#2 313/128/413 across its three tops, #3 as the pathfinder); T3 is authored + OSS-linted on
#1 (DDR self-refresh), #3 and #4 (LPDDR5X low-power), a single-always-on-domain contract on
the #2 protocol bridge (no gating partition — honest n/a rather than a fabricated domain),
and #5 carries the richest T3 (authored UPF + P0→P2→P0 power-aware test). The flow halves
live in the kit as templates. **T6 and T7 are now pathfound on #3 and rolled out to #1/#2/#4**
(promoted to the kit as `templates/signoff/{gls,ppa,pkg}`): **T6** = `make gls` zero-delay
gate-level sim (the synthesized netlist runs the block's own self-checking TB clean, via
Yosys simcells/simlib) + `make ppa` technology-independent PPA proxy (cells/flops/logic-depth);
**T7** = IP-XACT (IEEE 1685-2014) components + integration guide, gated by `make pkg`
(well-formed + structural + a hard IP-XACT↔RTL port-sync check), all OSS and in CI. The
rollout kept the gate honest per block: **#1** passes GLS+PPA+pkg (the GLS template was
hardened to auto-extract the TB's behavioural param overrides and synthesize the netlist at
them via `chparam`, so `DFI_INIT_START_CYCLES=4` actually takes effect; pkg 71/71); **#3**
(pathfinder) 2 tops; **#4** passes PPA+pkg (22/22) but its OSS zero-delay GLS does **not**
close — the unreset dual-clock async-FIFO RAM (lowered to registers by generic synth) reads
X (pessimism, not a bug: RTL sim + formal pass; #1's GLS passes) — so GLS is authored,
documented and left needs-pdk, not forced green; **#2** (Chisel) passes PPA (3 tops) + pkg
(53/36/68), and since its self-checking TBs are C++ Verilator harnesses the iverilog GLS is
n/a (the Verilator-netlist recipe is authored instead — no hollow gate). Their needs-pdk /
needs-license layers stay tagged (SDF-timing GLS, Liberty-mapped synth, real STA/area/power,
formal RTL↔netlist LEC). Next: **#5**'s T6/T7 (slang) waits on the GitHub Actions quota
reset (private repo). **T0 and T5 remain furthest along** otherwise (DV is strong across the
board). #1 also carries real **RTL-completion** debt behind its passing synth sanity.

---

## 7. Program-level exit criteria

The program is "done" when, for each block:
- all eight T-gates are passed with cited artifacts, **or** explicitly declared
  *sign-off-ready collateral* for any gate gated on licenses/PDK this program does not have;
- a signed `syn/SIGNOFF.md` checklist exists;
- a versioned, tagged release with an IP deliverable manifest exists;
- controlled-spec provenance and repo visibility are correct (private where required).

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
