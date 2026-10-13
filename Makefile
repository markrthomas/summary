PANDOC ?= pandoc
PANDOCDEF ?= $(CURDIR)/.pandoc-pdf-defaults.yaml
PANDOC_PDF_OPTS ?=
PYTHON ?= python3

# All RTL/DV repos; each exposes the DV_STANDARDS.md targets (make audit checks this).
RTL_REPOS := IP-axi-to-2apbs IP-ucie-rdi-to-pcie-pipe axi4_to_dfi_ddr chi-to-bow-bridge \
             ucie-cxl-bridge tilelink_to_AXI4 cxl_lpddr5x_bridge chi-to-cxl-bridge \
             chi-to-ucie-bridge ucie_rdi_to_pcie6_pipe7 si5_prep axi-on-ucie-to-mem \
             ucie2-pipe7-bridge eth-dj-to-pcie-pipe-bridge eth-dj-pcie-pipe7_1-bridge \
             uvm_review apb-to-mem-all-py apb-to-mem-bazel

SRC := README.md
PDF_SRC := .README.report.md
TITLE_MD := .report-title.md
PDF_OUT := README.pdf
HTML_OUT := README.html
HEADER_TEX := .pandoc-header.tex

.DEFAULT_GOAL := update-readme

.PHONY: help pdf html clean distclean regress audit update-readme

update-readme:
	@$(PYTHON) "$(CURDIR)/update_readme.py"

# repos-<target>: run one standard target (lint sim regress coverage formal ci
# stress clean) in every RTL repo, keep going, and list the failures at the end.
# Repos missing from this checkout are skipped.
repos-%:
	@fail=""; \
	for r in $(RTL_REPOS); do \
	  if [ ! -d "$(CURDIR)/$$r" ]; then echo "[$*] $$r: not checked out, skipped"; continue; fi; \
	  echo "[$*] $$r ..."; \
	  $(MAKE) -C "$(CURDIR)/$$r" $* || fail="$$fail $$r"; \
	done; \
	if [ -n "$$fail" ]; then echo "[$*] FAILED in:$$fail"; exit 1; fi; \
	echo "[$*] All repos passed."

# Back-compat alias for the original aggregate.
regress: repos-regress

audit:
	@bash "$(CURDIR)/dv_audit.sh"

help:
	@echo "Targets:"
	@echo "  make (no args) - Run update-readme (default goal)"
	@echo "  make update-readme - Refresh README.md per-repo state via update_readme.py"
	@echo "  make pdf   - Convert $(SRC) to $(PDF_OUT) (Pandoc + XeLaTeX + DejaVu; see .pandoc-pdf-defaults.yaml)"
	@echo "  make html  - Convert $(SRC) to $(HTML_OUT)"
	@echo "  make repos-<t> - Run standard target <t> (lint sim regress coverage formal ci stress clean) in every RTL repo"
	@echo "  make regress - Alias for repos-regress"
	@echo "  make audit - Check every RTL repo exposes the standard targets (dv_audit.sh)"
	@echo "  make clean - Remove generated documents, coverage info, PDF previews, .pytest_cache"
	@echo "  make distclean - Alias for clean"

pdf: $(PDF_OUT)

$(PDF_SRC): $(TITLE_MD) $(SRC)
	cp "$(TITLE_MD)" "$(PDF_SRC)"
	printf '\n' >> "$(PDF_SRC)"
	sed '1{/^# /d;}' "$(SRC)" >> "$(PDF_SRC)"

$(PDF_OUT): $(PDF_SRC) $(HEADER_TEX) $(PANDOCDEF)
	$(PANDOC) --defaults "$(PANDOCDEF)" $(PANDOC_PDF_OPTS) -H "$(HEADER_TEX)" "$(PDF_SRC)" -o "$(PDF_OUT)"

html: $(HTML_OUT)

$(HTML_OUT): $(SRC)
	$(PANDOC) "$(SRC)" -s --toc -o "$(HTML_OUT)"

clean:
	rm -f "$(PDF_OUT)" "$(HTML_OUT)" "$(PDF_SRC)"
	rm -f coverage.info coverage_burst.info coverage_simple.info
	rm -f readme-page-*.png
	rm -rf .pytest_cache

distclean: clean
