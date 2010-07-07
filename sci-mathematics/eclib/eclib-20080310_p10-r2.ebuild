# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit eutils sage versionator

MY_P="${PN}-$(replace_version_separator 1 '.')"

DESCRIPTION="Programs for enumerating and computing with elliptic curves defined over the rational numbers."
HOMEPAGE="http://www.warwick.ac.uk/~masgaj/mwrank/index.html"
SRC_URI="mirror://sage/spkg/standard/${MY_P}.spkg -> ${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="-pari24"

RESTRICT="mirror"

RDEPEND="dev-libs/gmp
	pari24? ( sci-mathematics/pari:3 )
	!pari24? ( >=sci-mathematics/pari-2.3.3:0 )
	>=dev-libs/ntl-5.4.2"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_P}/src"

src_prepare() {
	# patch for shared objects and various make issues.
	epatch "${FILESDIR}"/${P}-makefiles.patch.bz2

	if use pari24 ; then
		sed -i "s:-lpari:-lpari24:g" g0n/Makefile || die "failed to patch g0n/Makefile for pari24"
		sed -i "s:/usr/local/bin/gp:${EPREFIX}/usr/bin/gp-2.4:" \
			procs/gpslave.cc || die "failed to set the right path for pari/gp"
		sed -i "s:pari/pari:pari24/pari:" procs/parifact.cc || die "failed to patch pari24 headers"
		sed -i "s:-lpari:-lpari24:g" procs/Makefile || die "failed to patch procs/Makefile for pari24"
		sed -i "s:-lpari:-lpari24:g" qcurves/Makefile || die "failed to patch qcurves/Makefile for pari24"
		sed -i "s:-lpari:-lpari24:g" qrank/Makefile || die "failed to patch qrank/Makefile for pari24"
	else
		sed -i "s:/usr/local/bin/gp:${EPREFIX}/usr/bin/gp:" \
			procs/gpslave.cc || die "failed to set the right path for pari/gp"
	fi
}

src_compile() {
	emake all so || die
}

src_install() {
	dobin bin/* || die
	dolib.so lib/*.so* || die
	insinto /usr/include/eclib
	doins include/* || die
}

src_test() {
	emake allcheck || die
}
