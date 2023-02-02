NAMES=talk

all: $(addsuffix .pdf, $(NAMES))

$(addsuffix .pdf,$(NAMES)): $(addsuffix .tex, $(NAMES)) Makefile commands.tex graphics/*.pdf
	latexmk -f -pdf -pdflatex="pdflatex -interaction=nonstopmode" -use-make $(subst .pdf,.tex,$@)
	pdfcompress mg_bk_etmc_meeting2023.pdf talk.pdf /printer

clean:
	latexmk -f -c
	rm mg_bk_etmc_meeting2023.pdf

distclean:
	latexmk -f -CA
	rm -f $(addsuffix .pdf,$(NAMES))
	rm -f $(addsuffix .nav,$(NAMES))
	rm -f $(addsuffix .snm,$(NAMES))
	rm mg_bk_etmc_meeting2023.pdf
