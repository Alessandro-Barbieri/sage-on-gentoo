# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils

DESCRIPTION="A library for polynomial arithmetic"
HOMEPAGE="http://www.cims.nyu.edu/~harvey/zn_poly"
SRC_URI="http://www.cims.nyu.edu/~harvey/zn_poly/releases/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# TODO: License ?

# TODO: DEPENDs are only a guess
CDEPEND=">=dev-libs/gmp-4.2.4"
DEPEND="${CDEPEND}
	dev-lang/python"
RDEPEND="${CDEPEND}"

# TODO: --ntl-prefix= --use-flint --flint-prefix=

src_configure() {
	MY_CFLAGS="${CFLAGS}"

	# fixes bug on amd64
	if use amd64 ; then
		MY_CFLAGS="${MY_CFLAGS} -fPIC"
	fi

	# this command actually calls a python script
	./configure \
		--prefix=${D}/usr \
		--cflags="${MY_CFLAGS}" \
		--ldflags="${LDFLAGS}" \
		--gmp-prefix=/usr \
		|| die "configure failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc CHANGES
}
