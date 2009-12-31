# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit fortran multilib python sage

DESCRIPTION="Math software for algebra, geometry, number theory, cryptography,
and numerical computation."
HOMEPAGE="http://www.sagemath.org"
SRC_URI="http://mirror.switch.ch/mirror/sagemath/src/${P}.tar"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# TODO: should be sci-libs/m4ri-20091120 which is not available on upstream
CDEPEND="
	>=dev-libs/mpfr-2.4.1
	|| (
		>=dev-libs/ntl-5.4.2[gmp]
		>=dev-libs/ntl-5.5.2
	)
	>=net-libs/gnutls-2.2.1
	>=sci-libs/gsl-1.10
	>=sci-mathematics/pari-2.3.3[data,gmp]
	>=sys-libs/zlib-1.2.3
	>=app-arch/bzip2-1.0.5
	>=dev-util/mercurial-1.3.1
	>=sys-libs/readline-6.0
	>=media-libs/libpng-1.2.35
	>=dev-db/sqlite-3.6.17
	>=media-libs/gd-2.0.35
	>=media-libs/freetype-2.3.5
	>=sci-libs/linbox-1.1.6[ntl,sage]
	>=sci-libs/mpfi-1.3.4
	=sci-libs/givaro-3.2*
	>=sci-libs/iml-1.0.1
	>=sci-libs/zn_poly-0.9
	>=sci-mathematics/maxima-5.19.1[ecl,-sbcl]
	>=sci-libs/mpir-1.2.2[-nocxx]
	>=sci-libs/libfplll-3.0.12
	>=sci-mathematics/ecm-6.2.1
	>=media-gfx/tachyon-0.98
	>=sci-mathematics/eclib-20080310
	>=sci-mathematics/lcalc-1.23[pari]
	>=sci-mathematics/genus2reduction-0.3
	>=dev-lang/R-2.9.2[lapack,readline]
	>=sci-libs/m4ri-20091101
	>=sci-mathematics/gap-4.1.2
	>=sci-mathematics/gap-guava-3.4
	>=sci-mathematics/palp-1.1
	>=sci-mathematics/ratpoints-2.1.2
	>=sci-libs/libcliquer-1.2.2
	>=dev-lang/f2c-20060507
	virtual/cblas
	virtual/lapack
	>=sci-libs/cddlib-094f
	=sci-mathematics/gfan-0.3*
	>=sci-libs/flint-1.5.0[ntl]
	>=sci-mathematics/flintqs-20070817_p4
	=sci-mathematics/sage-data-${PV}
	=sci-mathematics/sage-extcode-${PV}
	>=sci-libs/symmetrica-2.0
	>=sci-mathematics/sympow-1.018
	>=sci-mathematics/rubiks-20070912_p9
	=sci-mathematics/sage-examples-${PV}
	>=dev-python/cython-0.12
	>=dev-python/setuptools-0.6.9
	>=dev-python/docutils-0.5
	>=sci-libs/scipy-0.7
	>=dev-python/numpy-1.3.0[lapack]
	>=dev-python/cvxopt-0.9
"

DEPEND="
	${CDEPEND}
	dev-util/pkgconfig
	>=dev-util/scons-1.2.0
"
RDEPEND="${CDEPEND}"

# tests _will_ fail!
RESTRICT="mirror test"

# TODO: Support maxima with clisp ? Problems that may arise: readline+clisp

# TODO: In order to remove Singular, pay attention to the following steps:
# DEPEND: >=sci-mathematics/singular-3.1.0.4-r1
# rewrite singular ebuild to correctly install libsingular
# check if sage needs a script and specific patches for library
# -e "s:ln -sf Singular sage_singular:ln -sf /usr/bin/Singular sage_singular:g" \
# -e "s:\$SAGE_LOCAL/share/singular:/usr/share/singular:g" \
# 	# fix path to singular headers
# 	sage_package_patch "${P}" "${FILESDIR}/${PN}-4.2.1-singular-path-fix.patch"

# TODO: install a menu icon for sage (see homepage and newsgroup for icon, etc)

pkg_setup() {
	FORTRAN="gfortran"

	fortran_pkg_setup

	# force sage to use our fortran compiler
	export SAGE_FORTRAN="$(which ${FORTRANC})"

	einfo "Sage itself is released under the GPL-2 _or later_ license"
	einfo "However sage is distributed with packages having different licenses."
	einfo "This ebuild unfortunately does too, here is a list of licenses used:"
	einfo "BSD, LGPL, apache 2.0, PYTHON, MIT, public-domain, ZPL and as-is"
}

src_prepare(){
	# verbosity only blows up build.log and slows down installation
	sed -i "s:cp -rpv:cp -rp:g" makefile || die "sed failed"

	# change to Sage's package directory
	cd "${S}"/spkg/standard

	# disable automatic generation of documentation, will be built manually
	sage_package_sed "sage_scripts-${PV}" -i \
		"/\"\$SAGE_ROOT\"\/sage -docbuild all html/d" install

# 	# but include a patch to let sage-doc build it
# 	sage_package_patch "sage-${PV}" \
# 		"${FILESDIR}/${PN}-4.2.1-documentation.patch"

	# do not let Sage make the following targets
	sage_clean_targets ATLAS BLAS BOEHM_GC CDDLIB CLIQUER CONWAY CVXOPT CYTHON \
		DOCUTILS ECLIB ECM ELLIPTIC_CURVES EXAMPLES EXTCODE F2C FLINT FLINTQS \
		FPLLL FREETYPE G2RED GAP GD GFAN GIVARO GNUTLS GRAPHS GSL IML LAPACK \
		LCALC LIBM4RI LIBPNG LINBOX MAXIMA MERCURIAL MPFI MPFR MPIR NTL NUMPY \
		PALP PARI POLYTOPES_DB RATPOINTS READLINE RUBIKS SAGE_BZIP2 SCIPY \
		SCONS SETUPTOOLS SQLITE SYMMETRICA SYMPOW TACHYON WEAVE ZLIB ZNPOLY

	# patch to make correct symbolic links
	sage_package_sed "sage_scripts-${PV}" -i \
		-e "s:ln -sf gp sage_pari:ln -sf /usr/bin/gp sage_pari:g" \
		spkg-install sage-spkg-install

	# TODO: gphelp is installed only if pari was emerged with USE=doc and
	# documentation additionally needs FEATURES=nodoc _not_ set.
	# TODO: fix directories containing version strings

	# fix pari, ecl, R and singular paths
	sage_package_sed "sage_scripts-${PV}" -i \
		-e "s:\$SAGE_LOCAL/share/pari:/usr/share/pari:g" \
		-e "s:\$SAGE_LOCAL/bin/gphelp:/usr/bin/gphelp:g" \
		-e "s:\$SAGE_LOCAL/share/pari/doc:/usr/share/doc/pari-2.3.4-r1:g" \
		-e "s:\$SAGE_ROOT/local/lib/R/lib:/usr/lib/R/lib:g" \
		-e "s:\$SAGE_LOCAL/lib/R:/usr/lib/R:g" \
		sage-env

	# comment out the line with ECLDIR=... - maxima should work without it
	sage_package_sed "sage_scripts-${PV}" -i \
		-e "s:ECLDIR=:#ECLDIR=:g" sage-env

# 	# patch to use atlas from portage
# 	sage_package_sed cvxopt-0.9.p8 -i "s:f77blas:blas:g" patches/setup_f95.py \
# 		patches/setup_gfortran.py

	# fix command for calling maxima
	sage_package_sed "sage-${PV}" -i "s:maxima-noreadline:maxima:g" \
		sage/interfaces/maxima.py

	# extcode is installed in a separate ebuild - fix directory path
	sage_package_sed "moin-1.5.7.p3" -i \
		"s:../../../../data:${SAGE_DATA}:g" spkg-install

	# do not compile R, but rpy2 which is in R's spkg (why ?)
	sage_package_patch r-2.9.2 "${FILESDIR}/${P}-use-R-from-portage.patch"

	# fix RHOME in rpy2
	sage_package_nested_sed r-2.9.2 rpy2-2.0.6 -i \
		"s:\"\$SAGE_LOCAL\"/lib/R:/usr/lib/R:g" \
		spkg-install

	# fix compilation error for rpy2
	sage_package_nested_patch r-2.9.2 rpy2-2.0.6 \
		"${FILESDIR}/${P}-fix-rpy2.patch"

	# TODO: customizing PYTHONPATH yields build errors without using python
	# packages from portage because of cython
	# add system path for python modules
	sage_package_sed "sage_scripts-${PV}" -i \
		-e "s:PYTHONPATH=\"\(.*\)\":PYTHONPATH=\"\1\:$(python_get_sitedir)\":g" \
		sage-env

	# set path to Sage's cython
	sage_package_sed "${P}" -i \
		-e "s:SAGE_LOCAL + '/lib/python/site-packages/Cython/Includes/':'/usr/lib/python2.6/site-packages/Cython/Includes/':g" \
		setup.py

	# do not download Twisted - TODO: look for another way to solve this
	sage_package_sed sagenb-0.4.8 -i "s:twisted>=8.2::g" \
		src/sagenb.egg-info/requires.txt
	sage_package_sed sagenb-0.4.8 -i \
		"/install_requires = \['twisted>=8\.2'\],/d" src/setup.py

	# TODO: Are these needed ?
	sage_package_sed "${P}" -i \
		-e "s:SAGE_ROOT +'/local/include/fplll':'/usr/include/fplll':g" \
		-e "s:SAGE_ROOT + \"/local/include/ecm.h\":\"/usr/include/ecm.h\":g" \
		-e "s:SAGE_ROOT + \"/local/include/png.h\":\"/usr/include/png.h\":g" \
		-e "s:SAGE_ROOT + \"/local/include/symmetrica/def.h\":\"/usr/include/symmetrica/def.h\":g" \
		module_list.py

	# TODO: -e "s:SAGE_ROOT + \"/local/include/fplll/fplll.h\":\"\":g" \
	# this file does not exist

	# make Sage be able to find flint's headers
	sage_package_sed "${P}" -i \
		-e "s:SAGE_ROOT+'/local/include/FLINT/':'/usr/include/FLINT/':g" \
		-e "s:SAGE_ROOT + \"/local/include/FLINT/flint.h\":\"/usr/include/FLINT/flint.h\":g" \
		module_list.py

	# fix numpy's include directory
	sage_package_sed "${P}" -i \
		-e "s:SAGE_ROOT+'/local/lib/python/site-packages/numpy/core/include':'/usr/lib/python2.6/site-packages/numpy/core/include':g" \
		module_list.py

	# this file is taken from portage's scipy ebuild
	cat > "${T}"/site.cfg <<-EOF
		[DEFAULT]
		library_dirs = /usr/$(get_libdir)
		include_dirs = /usr/include
		[atlas]
		include_dirs = $(pkg-config --cflags-only-I \
			cblas | sed -e 's/^-I//' -e 's/ -I/:/g')
		library_dirs = $(pkg-config --libs-only-L \
			cblas blas lapack| sed -e \
			's/^-L//' -e 's/ -L/:/g' -e 's/ //g'):/usr/$(get_libdir)
		atlas_libs = $(pkg-config --libs-only-l \
			cblas blas | sed -e 's/^-l//' -e 's/ -l/, /g' -e 's/,.pthread//g')
		lapack_libs = $(pkg-config --libs-only-l \
			lapack | sed -e 's/^-l//' -e 's/ -l/, /g' -e 's/,.pthread//g')
		[blas_opt]
			include_dirs = $(pkg-config --cflags-only-I \
			cblas | sed -e 's/^-I//' -e 's/ -I/:/g')
		library_dirs = $(pkg-config --libs-only-L \
		cblas blas | sed -e 's/^-L//' -e 's/ -L/:/g' \
			-e 's/ //g'):/usr/$(get_libdir)
		libraries = $(pkg-config --libs-only-l \
			cblas blas | sed -e 's/^-l//' -e 's/ -l/, /g' -e 's/,.pthread//g')
		[lapack_opt]
		library_dirs = $(pkg-config --libs-only-L \
		lapack | sed -e 's/^-L//' -e 's/ -L/:/g' \
			-e 's/ //g'):/usr/$(get_libdir)
		libraries = $(pkg-config --libs-only-l \
		lapack | sed -e 's/^-l//' -e 's/ -l/, /g' -e 's/,.pthread//g')
	EOF

	# copy file into scipy's spkg and scipy_sandbox
# 	sage_package_cp scipy-0.7.p3 "${T}"/site.cfg src/site.cfg
	sage_package_cp scipy_sandbox-20071020.p4 "${T}"/site.cfg arpack/site.cfg
	sage_package_cp scipy_sandbox-20071020.p4 "${T}"/site.cfg delaunay/site.cfg

	# unset custom C(XX)FLAGS on amd64 - this is just a temporary hack
	if use amd64 ; then
		sage_package_patch "${P}" "${FILESDIR}/${P}-amd64-hack.patch"
	fi

	# fix importing of deprecated sets module
	sage_package_patch "${P}" "${FILESDIR}/${P}-fix-deprecation-warning.patch"

	# pack all unpacked spkgs
	sage_package_finish

	# make symbolic links to data and examples
	ln -s "${SAGE_ROOT}"/data "${S}"/data || die "ln failed"
	ln -s "${SAGE_ROOT}"/examples "${S}"/examples || die "ln failed"
}

src_compile() {
	# do not run parallel since this is not possible at this level
	emake -j1 || die "emake failed"

	# build documentation
	"${S}"/sage -docbuild all html

	# check if everything did successfully built
	grep -s "Error building Sage" install.log && die "Sage build failed"
}

src_install() {
	# remove *.spkg files which will not be needed since sage must be upgraded
	# using portage, this saves about 400 MB
	for i in spkg/standard/*.spkg ; do
		rm $i
		touch $i
	done

	# these files are also not needed
	rm -rf spkg/build/*

	# remove mercurial directories - these are not needed
	hg_clean

	# install files
	emake DESTDIR="${D}/opt" install || die "emake install failed"

	# TODO: handle generated docs
	dodoc README.txt || die "dodoc failed"

	# set sage's correct path to /opt/sage
	sed -i "s:${D}::" "${D}"/opt/bin/sage "${D}"/opt/sage/sage \
		|| die "sed failed"
}

pkg_postinst() {
	# make sure files are correctly setup in the new location by running sage
	# as root. This prevent nasty message to be presented to the user.
	"${SAGE_ROOT}"/sage -c quit
}
