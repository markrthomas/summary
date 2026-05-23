PANDOC ?= pandoc
PANDOCDEF ?= $(CURDIR)/.pandoc-pdf-defaults.yaml
PANDOC_PDF_OPTS ?=
PYTHON ?= python3

RTL_REPOS := IP-axi-to-2apbs chi-to-bow-bridge axi4_to_dfi_ddr ucie-cxl-bridge IP-ucie-rdi-to-pcie-pipe si5_prep

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

regress:
	@for r in $(RTL_REPOS); do \
	  case "$$r" in \
	    si5_prep) tgt=regression ;; \
	    *)        tgt=regress ;; \
	  esac; \
	  echo "[REGRESS] $$r ($$tgt) ..."; \
	  $(MAKE) -C "$(CURDIR)/$$r" $$tgt || exit 1; \
	done
	@echo "[REGRESS] All repos passed."

audit:
	@bash "$(CURDIR)/dv_audit.sh"

help:
	@echo "Targets:"
	@echo "  make (no args) - Run update-readme (default goal)"
	@echo "  make update-readme - Refresh README.md per-repo state via update_readme.py"
	@echo "  make pdf   - Convert $(SRC) to $(PDF_OUT) (Pandoc + XeLaTeX + DejaVu; see .pandoc-pdf-defaults.yaml)"
	@echo "  make html  - Convert $(SRC) to $(HTML_OUT)"
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
