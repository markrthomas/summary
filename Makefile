PANDOC ?= pandoc
PDF_ENGINE ?= pdflatex
SRC := README.md
PDF_SRC := .README.report.md
TITLE_MD := .report-title.md
PDF_OUT := README.pdf
HTML_OUT := README.html
HEADER_TEX := .pandoc-header.tex

.PHONY: help pdf html clean distclean

help:
	@echo "Targets:"
	@echo "  make pdf   - Convert $(SRC) to $(PDF_OUT)"
	@echo "  make html  - Convert $(SRC) to $(HTML_OUT)"
	@echo "  make clean - Remove generated documents"
	@echo "  make distclean - Also remove local PDF preview artifacts"

pdf: $(PDF_OUT)

$(PDF_SRC): $(TITLE_MD) $(SRC)
	cp "$(TITLE_MD)" "$(PDF_SRC)"
	printf '\n' >> "$(PDF_SRC)"
	sed '1{/^# /d;}' "$(SRC)" >> "$(PDF_SRC)"

$(PDF_OUT): $(PDF_SRC) $(HEADER_TEX)
	$(PANDOC) "$(PDF_SRC)" -o "$(PDF_OUT)" --pdf-engine="$(PDF_ENGINE)" \
		--standalone \
		--toc \
		--metadata title="Project Repositories Summary" \
		-V geometry:margin=1in \
		-V fontsize=11pt \
		-V linestretch=1.1 \
		-V colorlinks=true \
		-H "$(HEADER_TEX)"

html: $(HTML_OUT)

$(HTML_OUT): $(SRC)
	$(PANDOC) "$(SRC)" -s --toc -o "$(HTML_OUT)"

clean:
	rm -f "$(PDF_OUT)" "$(HTML_OUT)" "$(PDF_SRC)"

distclean: clean
	rm -f readme-page-*.png
