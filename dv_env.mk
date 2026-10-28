# Canonical DV tool version pins for this workspace.
# Soft-included by RTL repo Makefiles; read by dv_audit.sh and tools/check_tools.sh.
# To upgrade: edit here, run `make audit` from workspace root, update each repo's
# Dockerfile/CI, and re-run the per-repo `make tools-check`.
#
# Each repo's Dockerfile remains the authoritative, buildable source of truth;
# these pins are the shared baseline the audit checks against. Where a repo
# deliberately diverges, it is noted below and the audit treats it as expected.

# --- Python DV libraries (pip) -----------------------------------------------
# The workspace is mid-migration on cocotb, so two pins are currently in use:
#   cocotb==1.8.1 : eth-dj-pcie-pipe7_1-bridge, pcie-on-ucie-3d
#   cocotb==1.9.2 : axi-on-ucie-to-mem, ucie2-pipe7-bridge  (newer PyUVM tier)
# COCOTB_PIP_SPEC is the baseline; COCOTB_ACCEPTED lists every pin the audit treats
# as OK. A repo pinned to anything NOT in COCOTB_ACCEPTED (or left unpinned) is
# flagged. Converge the set to a single value once the migration completes.
COCOTB_PIP_SPEC       ?= cocotb==1.8.1
COCOTB_ACCEPTED       ?= 1.8.1 1.9.2
PYUVM_PIP_SPEC        ?= pyuvm==4.0.1
PYVSC_PIP_SPEC        ?= pyvsc

# --- Simulators / synthesis --------------------------------------------------
# Verilator: UVM --binary flow needs a from-source, UVM-capable build; apt is too old.
VERILATOR_VERSION     ?= 5.050
VERILATOR_MIN         ?= 5.030
# Icarus: SV package syntax needs >= 12 (Ubuntu 24.04 apt = 12; 22.04 apt = 11, too old).
ICARUS_MIN            ?= 12
# SystemC (apt libsystemc-dev).
SYSTEMC_MIN           ?= 2.3.3

# --- Formal ------------------------------------------------------------------
# Yosys with the NATIVE slang frontend (read_slang), built from source; SymbiYosys (sby).
YOSYS_REF             ?= 47595d984
# Formal `cover` solver: yices is memory-light and preferred; apt z3 can OOM on deep covers.
YICES_VERSION         ?= 2.6.5
