# Copyright 2013 Jeffrey Kegler
# This file is part of Marpa::R2.  Marpa::R2 is free software: you can
# redistribute it and/or modify it under the terms of the GNU Lesser
# General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Marpa::R2 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser
# General Public License along with Marpa::R2.  If not, see
# http://www.gnu.org/licenses/.

# uncomment the second line if you use pdftex to bypass .dvi files
#PDFTEX = dvipdfm
PDFTEX = pdftex

CWEAVE = cweave
CTANGLE = ctangle

MARPA_PDF_SOURCES = cwebmac.tex marpa.w copyright_page_license.w

.PHONY: install docs

# Order matters -- configure.ac must be first
DOC_SOURCE_FILES = \
    ../doc/configure.ac \
    ../doc/Makefile.am \
    ../doc/fdl-1.3.texi \
    ../doc/lgpl-3.0.texi \
    ../doc/api.texi \
    ../doc/internal.texi \
    ../doc/NEWS \
    ../doc/README \
    ../doc/ChangeLog \
    ../doc/COPYING.LESSER \
    ../doc/AUTHORS

# Order matters -- configure.ac must be first
CONFIGURE_FILES = \
    ../stage/configure.ac \
    ../stage/Makefile.am

STAGE_FILES = \
    $(CONFIGURE_FILES) \
    ../stage/codes.c \
    ../stage/codes.h \
    ../stage/marpa.c \
    ../stage/marpa.h \
    ../stage/marpa_api.h \
    ../stage/marpa_util.h \
    ../stage/marpa_obs.c \
    ../stage/marpa_obs.h \
    ../stage/avl.h \
    ../stage/private.h \
    ../stage/avl.c \
    ../stage/NEWS \
    ../stage/README \
    ../stage/ChangeLog \
    ../stage/COPYING.LESSER \
    ../stage/AUTHORS

.SUFFIXES: .dvi .tex .w .pdf

.w.tex:
	$(CWEAVE) $*

.tex.dvi:	
	tex $<

.w.dvi:
	make $*.tex
	make $*.dvi

.w.c:
	$(CTANGLE) $*

.w.o:
	make $*.c
	make $*.o

.w.pdf:
	make $*.tex
	case "$(PDFTEX)" in \
	 dvipdfm ) tex "\let\pdf+ \input $*"; dvipdfm $* ;; \
	 pdftex ) pdftex $* ;; \
	esac

all: marpa.pdf sources

sources: marpa.c marpa.h marpa_util.h marpa_api.h codes.h codes.c private.h

marpa.h marpa.c: copyright_page_license.w marpa.w
	$(CTANGLE) marpa.w

codes.c codes.h marpa_api.h: api.texi internal.texi texi2code.pl
	cat api.texi internal.texi | \
	  perl texi2code.pl marpa_api.h codes.h codes.c

private.h: marpa.w w2private_h.pl
	perl w2private_h.pl private.h < marpa.w

marpa.pdf: marpa.tex cwebmac.tex

../doc/configure.ac: doc_dist/configure.ac
	test -d ../doc || mkdir ../doc
	cp $? $@

../doc/Makefile.am: doc_dist/Makefile.am
	cp $? $@

../stage/configure.ac: dist/configure.ac
	test -d ../stage || mkdir ../stage
	cp $? $@

../stage/Makefile.am: dist/Makefile.am
	cp $? $@

../stage/codes.c: codes.c
	cp $? $@

../stage/codes.h: codes.h
	cp $? $@

../stage/marpa.c: marpa.c
	cp $? $@

../stage/marpa.h: marpa.h
	cp $? $@

../stage/marpa_api.h: marpa_api.h
	cp $? $@

../stage/marpa_util.h: marpa_util.h
	cp $? $@

../stage/marpa_obs.c: marpa_obs.c
	cp $? $@

../stage/marpa_obs.h: marpa_obs.h
	cp $? $@

../stage/avl.c: avl/avl.c
	cp $? $@

../stage/avl.h: avl/avl.h
	cp $? $@

../stage/private.h: private.h
	cp $? $@

../stage/README: dist/README
	cp $? $@

../stage/NEWS: dist/NEWS
	cp $? $@

../stage/AUTHORS: dist/AUTHORS
	cp $? $@

../stage/COPYING.LESSER: dist/COPYING.LESSER
	cp $? $@

../stage/ChangeLog: dist/ChangeLog
	cp $? $@

../doc/README: doc_dist/README
	cp $? $@

../doc/NEWS: doc_dist/NEWS
	cp $? $@

../doc/AUTHORS: doc_dist/AUTHORS
	cp $? $@

../doc/COPYING.LESSER: doc_dist/COPYING.LESSER
	cp $? $@

../doc/ChangeLog: doc_dist/ChangeLog
	cp $? $@

../doc/fdl-1.3.texi: doc_dist/fdl-1.3.texi
	cp $? $@

../doc/lgpl-3.0.texi: doc_dist/lgpl-3.0.texi
	cp $? $@

../doc/api.texi: api.texi
	cp $? $@

../doc/internal.texi: internal.texi
	cp $? $@

../stage/configure: $(STAGE_FILES)
	test -d ../stage || mkdir ../stage
	test -d ../stage/m4 || mkdir ../stage/m4
	cd ../stage && autoreconf -iv

../stage/Makefile: ../stage/configure
	cd ../stage && ../stage/configure

../doc/api.pdf: ../doc/Makefile ../doc/api.texi
	cd ../doc && make pdf

../doc/api.html/index.html: ../doc/Makefile ../doc/api.texi
	cd ../doc && make html

../doc/internal.pdf: ../doc/Makefile ../doc/internal.texi
	cd ../doc && make pdf

../doc/internal.html/index.html: ../doc/Makefile ../doc/internal.texi
	cd ../doc && make html

install: ../stage/stamp-h1 ../doc/stamp-h1

../stage/stamp-h1: ../stage/Makefile $(STAGE_FILES)
	(cd ../stage; make dist)
	date > $@

../doc/stamp-h1: ../doc/Makefile docs
	(cd ../doc; make dist)
	date > $@

../doc/configure: $(DOC_SOURCE_FILES)
	test -d ../doc/m4 || mkdir ../doc/m4
	cd ../doc && autoreconf -ivf

../doc/Makefile: ../doc/configure
	cd ../doc && ../doc/configure

docs: marpa.pdf ../doc/Makefile \
  ../doc/api.pdf ../doc/api.html/index.html \
  ../doc/internal.pdf ../doc/internal.html/index.html

update_texi:
	emacs -batch api.texi \
	    -f texinfo-every-node-update \
	    -f texinfo-all-menus-update \
	    -f save-buffer -kill
	emacs -batch internal.texi \
	    -f texinfo-every-node-update \
	    -f texinfo-all-menus-update \
	    -f save-buffer -kill
