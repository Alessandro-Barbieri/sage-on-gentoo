# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils flag-o-matic fortran

DESCRIPTION="Math software for algebra, geometry, number theory, cryptography,
and numerical computation."
HOMEPAGE="http://www.sagemath.org"
SRC_URI="http://mirror.switch.ch/mirror/sagemath/src/${P}.tar"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="sage-minimal doc examples"

# TODO: check dependencies

CDEPEND="
	!disable-mpfr? (
		>=dev-libs/mpfr-2.4.1
	)
	|| (
		>=dev-libs/ntl-5.4.2[gmp]
		>=dev-libs/ntl-5.5.2
	)
	>=net-libs/gnutls-2.2.1
	>=sci-libs/gsl-1.10
	>=sci-libs/lapack-atlas-3.8.3
	!disable-pari? (
		>=sci-mathematics/pari-2.3.3[data,gmp]
	)
	>=sys-libs/zlib-1.2.3
	>=app-arch/bzip2-1.0.5
	>=dev-util/mercurial-1.3.1
	>=sys-libs/readline-6.0
	>=media-libs/libpng-1.2.35
	>=dev-db/sqlite-3.6.17
	>=dev-util/scons-1.2.0
	>=media-libs/gd-2.0.35
	>=media-libs/freetype-2.3.5
	>=sci-libs/linbox-1.1.6[ntl,sage]
	>=sci-libs/mpfi-1.3.4
	>=sci-libs/givaro-3.2.13
	>=sci-libs/iml-1.0.1
	>=sci-libs/zn_poly-0.9"
DEPEND="${CDEPEND}
	>=app-arch/tar-1.20"
RDEPEND="${CDEPEND}"

# if we are reintroducing maxima, add the following lines to DEPEND:
# || (
# >=sci-mathematics/maxima-5.19.1[clisp,-sbcl]
# >=sci-mathematics/maxima-5.19.1[ecl,-sbcl]
# )
# this will make sure to build maxima without sbcl-lisp which is known to cause
# problems

# >=dev-lang/R-2.9.2[lapack,readline]

# TODO: Optimize spkg_* functions, so that one can use mutiple spkg_* calls on
# the same package without unpacking and repacking it everytime

spkg_unpack() {
	# untar spkg and and remove it
	tar -xf "$1.spkg"
	rm "$1.spkg"
	cd "$1"
}

spkg_pack() {
	# tar patched dir and remove it
	cd ..
	tar -cf "$1.spkg" "$1"
	rm -rf "$1"
}

# patch one of sage's spkgs. $1: spkg name, $2: patch name
spkg_patch() {
	spkg_unpack "$1"

	epatch "$2"

	spkg_pack "$1"
}

spkg_sed() {
	spkg_unpack "$1"

	SPKG="$1"
	shift 1
	sed "$@" || die "sed failed"

	spkg_pack "${SPKG}"
}

patch_deps_file() {
	for i in "$@"; do
		epatch "$FILESDIR/use-$i-from-portage.patch"
	done
}

pkg_setup() {
	FORTRAN="gfortran"

	fortran_pkg_setup

	# force sage to use our fortran compiler
	export SAGE_FORTRAN="${FORTRANC}"

	einfo "Sage itself is released under the GPL-2 _or later_ license"
	einfo "However sage is distributed with packages having different licenses."
	einfo "This ebuild unfortunately does too, here is a list of licenses used:"
	einfo "BSD, LGPL, apache 2.0, PYTHON, MIT, public-domain, ZPL and as-is"
}

src_prepare(){
	cd "${S}/spkg/standard"

	# fix sandbox violation errors
	spkg_patch "ecm-6.2.1.p0" "$FILESDIR/ecm-6.2.1.p0-fix-typo.patch"
	spkg_sed "zlib-1.2.3.p4" -i "/ldconfig/d" src/Makefile src/Makefile.in

	# do not generate documentation if not needed
	if ! use doc ; then
		# remove the following line which builds documentation
		sed -i "/\"\$SAGE_ROOT\"\/sage -docbuild all html/d" \
			"${S}/spkg/install" || die "sed failed"

		# remove the same line in the same files in sage_scripts spkg - this
		# package will unpack and overwrite the original "install" file (why ?)
		spkg_sed "sage_scripts-4.2" -i \
			"/\"\$SAGE_ROOT\"\/sage -docbuild all html/d" "install"

		# TODO: remove documentation and the related tests
	fi

	# do not make examples if not needed
	if ! use examples ; then
		epatch "$FILESDIR/deps-no-examples.patch"

		# TODO: remove examples and examples related tests
	fi

	# TODO: patch to set PYTHONPATH correctly for all python packages

	if ! use sage-minimal ; then
		# remove dependencies which will be provided by portage
		patch_deps_file atlas boehmgc bzip2 freetype givaro gd gnutls iml gsl \
	    	libpng linbox mercurial mpfi mpfr ntl pari readline scons sqlite \
			zlib znpoly

		# patches to use pari from portage
		spkg_patch "genus2reduction-0.3.p5" \
			"$FILESDIR/g2red-pari-include-fix.patch"
		spkg_patch "lcalc-20080205.p3" "$FILESDIR/lcalc-fix-paths.patch"
		spkg_patch "eclib-20080310.p7" "$FILESDIR/eclib-fix-paths.patch"

		# patch to make a correct symbolic link to gp
		spkg_sed "sage_scripts-4.2" -i \
			's/ln -sf gp sage_pari/ln -sf \/usr\/bin\/gp sage_pari/g' \
			"spkg-install" "sage-spkg-install"

		# FIX: some tests fail because of pari from portage (data related)

		# patches for sage on gentoo
		#spkg_patch "sage-4.2" "${FILESDIR}/sage-fix-paths.patch"

		# patch to use atlas from portage
		spkg_sed "cvxopt-0.9.p8" -i "s/f77blas/blas/g" "patches/setup_f95.py" \
			"patches/setup_gfortran.py"

		# TODO: more fortran patches needed, maybe: cvxopt, numpy, scipy
	fi
}

src_compile() {
	# This is so (at least) mpir will compile.
	ABI=32
	if ( (use amd64) || (use ppc64) ); then
		ABI=64
	fi

	emake || die "make failed"
	if ( grep "sage: An error occurred" "${S}/install.log" ); then
		die "make failed"
	fi
}

src_install() {
	emake DESTDIR="${D}/opt" install
	sed -i "s/SAGE_ROOT=.*\/opt/SAGE_ROOT=\"\/opt/" "${D}/opt/bin/sage" \
		"${D}/opt/sage/sage"

	# TODO: handle generated docs
	dodoc COPYING.txt HISTORY.txt README.txt || die "dodoc failed"

	# Force sage to create files in new location.  This has to be done twice -
	# this time to create the files for gentoo to correctly record as part of
	# the sage install
	"${D}/opt/sage/sage" -c quit
}

pkg_postinst() {
	# make sure files are correctly setup in the new location by running sage
	# as root. This prevent nasty message to be presented to the user.
	/opt/sage/sage -c quit
}
