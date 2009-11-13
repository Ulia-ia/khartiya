VERSION:=$(shell date +"%Y%m%d")
FAMILY=Khartiya
SFDFILES=$(FAMILY)-Regular.sfd $(FAMILY)-Italic.sfd $(FAMILY)-Bold.sfd $(FAMILY)-BoldItalic.sfd
DOCUMENTS=OFL.txt OFL-FAQ.txt FontLog.txt
OTFFILES=$(FAMILY)-Regular.otf $(FAMILY)-Italic.otf $(FAMILY)-Bold.otf $(FAMILY)-BoldItalic.otf
TTFFILES=$(FAMILY)-Regular.ttf $(FAMILY)-Italic.ttf $(FAMILY)-Bold.ttf $(FAMILY)-BoldItalic.ttf
PFBFILES=$(FAMILY)-Regular.pfb $(FAMILY)-Italic.pfb $(FAMILY)-Bold.pfb $(FAMILY)-BoldItalic.pfb
AFMFILES=$(FAMILY)-Regular.afm $(FAMILY)-Italic.afm $(FAMILY)-Bold.afm $(FAMILY)-BoldItalic.afm
FFSCRIPTS=generate.ff  spaces_dashes.ff  liga_sub.ff \
	COPYING.scripts
DIFFFILES=$(FAMILY)-Regular.gen.xgf.diff # $(FAMILY)-Italic.gen.xgf.diff $(FAMILY)-Bold.gen.xgf.diff $(FAMILY)-BoldItalic.gen.xgf.diff
XGFFILES=$(FAMILY)-Regular.ed.xgf # $(FAMILY)-Italic.ed.xgf $(FAMILY)-Bold.ed.xgf $(FAMILY)-BoldItalic.ed.xgf
COMPRESS=xz -9

all: $(OTFFILES) ttf

$(FAMILY)-Regular.otf: $(FAMILY)-Regular.sfd $(FFSCRIPTS)
	fontforge -lang=ff -script generate.ff $(FAMILY)-Regular UTRG__

$(FAMILY)-Italic.otf: $(FAMILY)-Italic.sfd $(FFSCRIPTS)
	fontforge -lang=ff -script generate.ff $(FAMILY)-Italic UTI___

$(FAMILY)-Bold.otf: $(FAMILY)-Bold.sfd $(FFSCRIPTS)
	fontforge -lang=ff -script generate.ff $(FAMILY)-Bold UTB___

$(FAMILY)-BoldItalic.otf: $(FAMILY)-BoldItalic.sfd $(FFSCRIPTS)
	fontforge -lang=ff -script generate.ff $(FAMILY)-BoldItalic UTBI__

%.pdf: %.otf
	fntsample -f $< -o $@

# We don't want to change anything in autoinstructed following faces:
$(FAMILY)-Italic.ttf: $(FAMILY)-Italic.gen.ttf $(FAMILY)-Italic.otf
	cp -p $(FAMILY)-Italic.gen.ttf $(FAMILY)-Italic.ttf

$(FAMILY)-Bold.ttf: $(FAMILY)-Bold.gen.ttf $(FAMILY)-Bold.otf
	cp -p $(FAMILY)-Bold.gen.ttf $(FAMILY)-Bold.ttf

$(FAMILY)-BoldItalic.ttf: $(FAMILY)-BoldItalic.gen.ttf $(FAMILY)-BoldItalic.otf
	cp -p $(FAMILY)-BoldItalic.gen.ttf $(FAMILY)-BoldItalic.ttf

$(FAMILY)-Regular.ttf: $(FAMILY)-Regular.otf

%.ttf: %.pe %.gen.ttf %.otf
	fontforge -lang=ff -script $*.pe

#%.gen.ttf: %.otf

%.gen.ttx: %.gen.ttf %.otf
	-rm $*.gen.ttx
	ttx $*.gen.ttf

%.gen.xgf: %.gen.ttx
	-rm $*.gen.xgf
	ttx2xgf $*.gen.ttx
#	patch -l --no-backup-if-mismatch < $*.gen.xgf.diff

%.xml: %.gen.xgf %.ed.xgf
	xgfmerge -o $@ $^

%.pe: %.xml
	xgridfit -p 25 -G no -i $*.gen.ttf -o $*.ttf $<

#$(FAMILY)-Regular.ttf: $(FAMILY)-Regular.pe # $(FAMILY)-Regular.gen.ttf
#	fontforge -lang=ff -script $(FAMILY)-Regular.pe

.SECONDARY : *.pe *.xml *.gen.xgf *.gen.ttx

ttf: $(TTFFILES)

dist-src:
	tar -cvf heuristica-src-$(VERSION).tar $(SFDFILES) Makefile \
	$(FFSCRIPTS) $(DOCUMENTS) $(XGFFILES) $(DIFFFILES)
	$(COMPRESS) heuristica-src-$(VERSION).tar

dist-otf: all
	tar -cvf heuristica-otf-$(VERSION).tar \
	$(OTFFILES) $(DOCUMENTS)
	$(COMPRESS) heuristica-otf-$(VERSION).tar

dist-ttf: all
	tar -cvf heuristica-ttf-$(VERSION).tar \
	$(TTFFILES) $(DOCUMENTS)
	$(COMPRESS) heuristica-ttf-$(VERSION).tar

dist-pfb: all
	tar -cvf heuristica-pfb-$(VERSION).tar \
	$(PFBFILES) $(AFMFILES) $(DOCUMENTS)
	$(COMPRESS) heuristica-pfb-$(VERSION).tar

dist: dist-src dist-otf dist-ttf

update-version:
	sed -e "s/^Version: .*$$/Version: $(VERSION)/" -i $(SFDFILES)

.PHONY : clean
clean :
	rm *.gen.ttx *..gen.xgf