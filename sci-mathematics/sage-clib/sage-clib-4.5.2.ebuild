# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit eutils toolchain-funcs

MY_P="sage-${PV}"

DESCRIPTION="Sage's C library"
HOMEPAGE="http://www.sagemath.org"
SRC_URI="mirror://sage/spkg/standard/${MY_P}.spkg -> sage-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

RESTRICT="mirror"

CDEPEND="dev-libs/gmp[-nocxx]
	>=dev-libs/ntl-5.4.2
	>=dev-lang/python-2.6.4
	>=sci-libs/pynac-0.2.0_p4
	>=sci-mathematics/pari-2.3.5
	>=sci-mathematics/polybori-0.6.4[sage]"
DEPEND="${CDEPEND}
	>=dev-util/scons-1.2.0"
RDEPEND="${CDEPEND}"

S="${WORKDIR}/${MY_P}/c_lib"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-4.5-importenv.patch

	# TODO: write new mpir patch ?
}

src_compile() {
	# build libcsage.so
	CXX= SAGE_LOCAL=/usr UNAME=$(uname) scons ${MAKEOPTS} \
		|| die "failed to compile"
}

src_install() {
	dolib.so libcsage.so || die
	insinto /usr/include/csage
	doins include/*.h || die
}
