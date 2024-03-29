VERSION:=$(shell date +"%Y%m%d")
FAMILY=Khartiya
PKGNAME=khartiya
SFDFILES=$(FAMILY)-Regular.sfd $(FAMILY)-Italic.sfd $(FAMILY)-Bold.sfd $(FAMILY)-BoldItalic.sfd
DOCUMENTS=OFL.txt OFL-FAQ.txt FontLog.txt
OTFFILES=$(FAMILY)-Regular.otf $(FAMILY)-Italic.otf $(FAMILY)-Bold.otf $(FAMILY)-BoldItalic.otf
TTFFILES=$(FAMILY)-Regular.ttf $(FAMILY)-Italic.ttf $(FAMILY)-Bold.ttf $(FAMILY)-BoldItalic.ttf
PFBFILES=$(FAMILY)-Regular.pfb $(FAMILY)-Italic.pfb $(FAMILY)-Bold.pfb $(FAMILY)-BoldItalic.pfb
AFMFILES=$(FAMILY)-Regular.afm $(FAMILY)-Italic.afm $(FAMILY)-Bold.afm $(FAMILY)-BoldItalic.afm
FFSCRIPTS=generate.ff 
EXTRAFFSCRIPTS=make_dup_vertshift.ff new_glyph.ff add_anchor_ext.ff \
	add_anchor_y.ff add_anchor_med.ff anchors.ff combining.ff make_comb.ff \
	dub_glyph.ff spaces_dashes.ff case_sub.ff hflip_glyph.ff \
	make_dup_rot.ff dub_glyph_ch.ff same_cyrext.ff \
	make_cap_accent.ff make_superscript.ff dub_aligned.ff same_kern.ff \
	make_kern.ff cop_kern_left.ff cop_kern_right.ff cop_kern_acc.ff \
	cop_kern.ff cop_kern_mult.ff copy_anchors_acc.ff liga_sub.ff
#DIFFFILES=$(FAMILY)-Regular.gen.xgf.diff # $(FAMILY)-Italic.gen.xgf.diff $(FAMILY)-Bold.gen.xgf.diff $(FAMILY)-BoldItalic.gen.xgf.diff
XGFFILES= upr_functions.xgf \
	$(FAMILY)-Regular.ed.xgf $(FAMILY)-Italic.ed.xgf $(FAMILY)-Bold.ed.xgf $(FAMILY)-BoldItalic.ed.xgf
COMPRESS=xz -9
TEXENC=t1,t2a,t2b,t2c,ts1,ot1
#PYTHON=python -W all
PYTHON=fontforge -lang=py -script 

TEXPREFIX=./texmf
INSTALL=install -m 644 -p
DESTDIR=
prefix=/usr
fontdir=$(prefix)/share/fonts/TTF
docdir=$(prefix)/doc/$(PKGNAME)

all: $(OTFFILES) ttf

$(FAMILY)-Regular.otf: $(FAMILY)-Regular.sfd $(FFSCRIPTS) $(EXTRAFFSCRIPTS)
	fontforge -lang=ff -script generate.ff $(FAMILY)-Regular UTRG__
	BASE=`basename $@ .otf`; \
	csplit --prefix=$${BASE}. $${BASE}.afm /StartKernData/ ; \
	ot2kpx $${BASE}.otf > $${BASE}.kpx; \
	cat $${BASE}.00 $${BASE}.kpx > $${BASE}.afm

$(FAMILY)-Italic.otf: $(FAMILY)-Italic.sfd $(FFSCRIPTS) $(EXTRAFFSCRIPTS)
	fontforge -lang=ff -script generate.ff $(FAMILY)-Italic UTI___
	BASE=`basename $@ .otf`; \
	csplit --prefix=$${BASE}. $${BASE}.afm /StartKernData/ ; \
	ot2kpx $${BASE}.otf > $${BASE}.kpx; \
	cat $${BASE}.00 $${BASE}.kpx > $${BASE}.afm

$(FAMILY)-Bold.otf: $(FAMILY)-Bold.sfd $(FFSCRIPTS) $(EXTRAFFSCRIPTS)
	fontforge -lang=ff -script generate.ff $(FAMILY)-Bold UTB___
	BASE=`basename $@ .otf`; \
	csplit --prefix=$${BASE}. $${BASE}.afm /StartKernData/ ; \
	ot2kpx $${BASE}.otf > $${BASE}.kpx; \
	cat $${BASE}.00 $${BASE}.kpx > $${BASE}.afm

$(FAMILY)-BoldItalic.otf: $(FAMILY)-BoldItalic.sfd $(FFSCRIPTS) $(EXTRAFFSCRIPTS)
	fontforge -lang=ff -script generate.ff $(FAMILY)-BoldItalic UTBI__
	BASE=`basename $@ .otf`; \
	csplit --prefix=$${BASE}. $${BASE}.afm /StartKernData/ ; \
	ot2kpx $${BASE}.otf > $${BASE}.kpx; \
	cat $${BASE}.00 $${BASE}.kpx > $${BASE}.afm

%.pdf: %.otf
	fntsample -f $< -o $@

# We don't want to change anything in autoinstructed following faces:
# $(FAMILY)-Italic.ttf: $(FAMILY)-Italic.gen.ttf $(FAMILY)-Italic.otf
# 	cp -p $(FAMILY)-Italic.gen.ttf $(FAMILY)-Italic.ttf
#
# $(FAMILY)-Bold.ttf: $(FAMILY)-Bold.gen.ttf $(FAMILY)-Bold.otf
# 	cp -p $(FAMILY)-Bold.gen.ttf $(FAMILY)-Bold.ttf
#
# $(FAMILY)-BoldItalic.ttf: $(FAMILY)-BoldItalic.gen.ttf $(FAMILY)-BoldItalic.otf
# 	cp -p $(FAMILY)-BoldItalic.gen.ttf $(FAMILY)-BoldItalic.ttf

$(FAMILY)-Regular_.sfd: $(FAMILY)-Regular.otf

$(FAMILY)-Bold_.sfd: $(FAMILY)-Bold.otf

$(FAMILY)-Italic_.sfd: $(FAMILY)-Italic.otf

$(FAMILY)-BoldItalic_.sfd: $(FAMILY)-BoldItalic.otf

$(FAMILY)-Regular_acc.xgf: $(FAMILY)-Regular_.sfd $(FAMILY)-Regular.otf inst_acc.py
	$(PYTHON) inst_acc.py -c -j -i $(FAMILY)-Regular_.sfd  -o $(FAMILY)-Regular_acc.xgf

$(FAMILY)-Bold_acc.xgf: $(FAMILY)-Bold_.sfd $(FAMILY)-Bold.otf inst_acc.py
	$(PYTHON) inst_acc.py -c -j -i $(FAMILY)-Bold_.sfd  -o $(FAMILY)-Bold_acc.xgf

%.ttf: %.py %_.sfd %.otf
	fontforge -lang=py -script $*.py

#%_.sfd: %.otf

#%.gen.ttx: %_.sfd %.otf
# 	-rm $*.gen.ttx
# 	ttx $*.gen.ttf

# %.gen.xgf: %.gen.ttx
# 	-rm $*.gen.xgf
# 	ttx2xgf $*.gen.ttx

# %.xml: %.gen.xgf %.ed.xgf
# 	xgfmerge -o $@ $^

%_acc.xgf: %_.sfd %.otf inst_acc.py
	$(PYTHON) inst_acc.py -i $*_.sfd  -o $*_acc.xgf

%.py: %.ed.xgf %_.sfd %_acc.xgf upr_functions.xgf
	xgridfit -m -p 25 -G no -i $*_.sfd -o $*.ttf -O $*.py $*.ed.xgf
#	xgridfit -p 25 -G no -i $*_.sfd -o $*.ttf $<

.SECONDARY : *.py *.xml *.gen.xgf *.gen.ttx *.00 *.01

ttf: $(OTFFILES) $(TTFFILES)

tex-support: all
	mkdir -p $(TEXPREFIX)
	-rm -rf ./texmf/*
	TEXMFVAR=$(TEXPREFIX) autoinst --encoding=$(TEXENC) -typeface=$(PKGNAME) \
	-vendor=public --extra="--no-updmap" \
	 -target=$(TEXPREFIX) \
	$(OTFFILES)
	mkdir -p $(TEXPREFIX)/fonts/enc/dvips/$(PKGNAME)
	#mv $(TEXPREFIX)/fonts/enc/dvips/public/* texmf/fonts/enc/dvips/$(PKGNAME)/
	-rm -rf $(TEXPREFIX)/fonts/truetype/public/$(PKGNAME)
	-rm -r $(TEXPREFIX)/fonts/truetype
	#mkdir -p texmf/tex/latex/$(PKGNAME)
	#mkdir -p texmf/fonts/map/dvips/$(PKGNAME)
	#mv *$(FAMILY)-TLF.fd texmf/tex/latex/$(PKGNAME)/
	mv $(TEXPREFIX)/tex/latex/$(PKGNAME)/$(FAMILY).sty $(TEXPREFIX)/tex/latex/$(PKGNAME)/$(PKGNAME).sty
	mv $(TEXPREFIX)/fonts/map/dvips/$(PKGNAME)/$(FAMILY).map $(TEXPREFIX)/fonts/map/dvips/$(PKGNAME)/$(PKGNAME).map
	mkdir -p $(TEXPREFIX)/dvips/$(PKGNAME)
	echo "p +$(PKGNAME).map" > $(TEXPREFIX)/dvips/$(PKGNAME)/config.$(PKGNAME)
	mkdir -p $(TEXPREFIX)/doc/fonts/$(PKGNAME)
	$(INSTALL) $(DOCUMENTS) $(TEXPREFIX)/doc/fonts/$(PKGNAME)/

dist-src:
	tar -cvf $(PKGNAME)-src-$(VERSION).tar $(SFDFILES) Makefile \
	$(FFSCRIPTS) $(DOCUMENTS) $(XGFFILES) $(DIFFFILES)
	$(COMPRESS) $(PKGNAME)-src-$(VERSION).tar

dist-otf: all
	tar -cvf $(PKGNAME)-otf-$(VERSION).tar \
	$(OTFFILES) $(DOCUMENTS)
	$(COMPRESS) $(PKGNAME)-otf-$(VERSION).tar

dist-ttf: all
	tar -cvf $(PKGNAME)-ttf-$(VERSION).tar \
	$(TTFFILES) $(DOCUMENTS)
	$(COMPRESS) $(PKGNAME)-ttf-$(VERSION).tar

dist-pfb: all
	tar -cvf $(PKGNAME)-pfb-$(VERSION).tar \
	$(PFBFILES) $(AFMFILES) $(DOCUMENTS)
	$(COMPRESS) $(PKGNAME)-pfb-$(VERSION).tar

dist-tex:
	( cd ./texmf ;\
	tar -cvf ../$(PKGNAME)-tex-$(VERSION).tar \
	doc dvips fonts tex )
	$(COMPRESS) $(PKGNAME)-tex-$(VERSION).tar

dist: dist-src dist-otf dist-ttf

update-version:
	sed -e "s/^Version: .*$$/Version: $(VERSION)/" -i $(SFDFILES)

.PHONY : clean
clean :
	rm *.gen.ttx *..gen.xgf *.00 *.01

distclean :
	-rm $(OTFFILES) $(TTFFILES) $(PFBFILES) $(AFMFILES) $(FAMILY)-*_.sfd

install:
	mkdir -p $(DESTDIR)$(fontdir)
	$(INSTALL) -p --mode=644 $(TTFFILES) $(DESTDIR)$(fontdir)/
	mkdir -p $(DESTDIR)$(docdir)
	$(INSTALL) -p --mode=644 $(DOCUMENTS) $(DESTDIR)$(docdir)/
