PANDOC ?= pandoc
PANDOCDEF ?= $(CURDIR)/.pandoc-pdf-defaults.yaml
PANDOC_PDF_OPTS ?=

SRC := README.md
PDF_SRC := .README.report.md
TITLE_MD := .report-title.md
PDF_OUT := README.pdf
HTML_OUT := README.html
HEADER_TEX := .pandoc-header.tex

.PHONY: help pdf html clean distclean

help:
	@echo "Targets:"
	@echo "  make pdf   - Convert $(SRC) to $(PDF_OUT) (Pandoc + XeLaTeX + DejaVu; see .pandoc-pdf-defaults.yaml)"
	@echo "  make html  - Convert $(SRC) to $(HTML_OUT)"
	@echo "  make clean - Remove generated documents"
	@echo "  make distclean - Also remove local PDF preview artifacts"

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

distclean: clean
	rm -f readme-page-*.png
