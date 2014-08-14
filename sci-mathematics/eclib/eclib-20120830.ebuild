# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils autotools-utils

DESCRIPTION="Programs for enumerating and computing with elliptic curves defined over the rational numbers."
HOMEPAGE="http://www.warwick.ac.uk/~masgaj/mwrank/index.html"
SRC_URI="mirror://sageupstream/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux ~x86-macos ~x64-macos"
IUSE="static-libs"

RESTRICT="mirror"

RDEPEND="dev-libs/gmp
	>=sci-mathematics/pari-2.5.0
	>=dev-libs/ntl-5.4.2"
DEPEND="${RDEPEND}"

src_prepare() {
	sed -i "s:/usr/local/bin/gp:${EPREFIX}/usr/bin/gp:" \
		libsrc/gpslave.cc || die "failed to set the right path for pari/gp"
}

src_configure() {
	local myeconfargs=(--disable-allprogs)

	autotools-utils_src_configure
}
