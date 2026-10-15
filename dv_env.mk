# Canonical DV tool version pins for this workspace.
# Soft-included by RTL repo Makefiles; read by dv_audit.sh.
# To upgrade: edit here, run `make audit` from workspace root, update CI files.

COCOTB_PIP_SPEC       ?= cocotb==1.8.1
