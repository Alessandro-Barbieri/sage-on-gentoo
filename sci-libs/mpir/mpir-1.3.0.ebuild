# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils autotools

DESCRIPTION="MPIR is a library for arbitrary precision integer arithmetic derived from version 4.2.1 of gmp"
HOMEPAGE="http://www.mpir.org/"
SRC_URI="http://www.mpir.org/${P}.tar.gz"
RESTRICT="mirror"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="nocxx cpudetection"

# Beware: cpudetection aka fat binaries only works on x86/amd64
# When we enable more cpus we will have to carefully filter.

DEPEND="dev-lang/yasm"
RDEPEND=""

src_prepare(){
	epatch "${FILESDIR}/${P}-yasm.patch"
	epatch "${FILESDIR}/${P}-ABI-multilib.patch"
	eautoreconf
}

src_configure() {
# beware that cpudetection aka fat binaries is x86/amd64 only.
# It will need to be filtered when extended to other archs
	econf \
		$(use_enable !nocxx cxx) \
		$(use_enable cpudetection fat) \
		|| "econf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc ChangeLog README NEWS
}
