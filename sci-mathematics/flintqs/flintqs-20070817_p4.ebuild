# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

SAGE_VERSION=4.3.3
SAGE_PACKAGE=flintqs-20070817.p4

inherit eutils sage

DESCRIPTION="William Hart's GPL'd highly optimized multi-polynomial quadratic
sieve for integer factorization"
# HOMEPAGE=""
# SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT="mirror"

DEPEND=""
RDEPEND="${DEPEND}"

src_prepare() {
	cp "${SAGE_FILESDIR}"/lanczos.h .

	if use amd64 ; then
		cp makefile.opteron makefile
	else
		cp makefile.sage makefile
	fi
}

src_install() {
	dobin QuadraticSieve
}
