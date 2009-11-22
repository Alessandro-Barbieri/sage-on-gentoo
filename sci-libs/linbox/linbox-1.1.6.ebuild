# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit autotools eutils

DESCRIPTION="LinBox is a C++ template library for linear algebra computation
over integers and over finite fields"
HOMEPAGE="http://linalg.org/"
SRC_URI="http://linalg.org/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc ntl sage"

# disabling commentator breaks the tests
RESTRICT="mirror
	sage? ( test )"

CDEPEND="dev-libs/gmp[-nocxx]
	~sci-libs/givaro-3.2.13
	ntl? ( dev-libs/ntl )
	virtual/cblas
	virtual/lapack"
DEPEND="${CDEPEND}
	doc? ( app-doc/doxygen )"
RDEPEND="${CDEPEND}"

# disabling of commentator class breaks the tests
RESTRICT="test"

src_prepare() {
	if use sage ; then
		# disable commentator; this is needed for sage
		epatch "${FILESDIR}/commentator-patch-from-sage.patch"
	fi

	if use doc ; then
		epatch "${FILESDIR}/${P}-fix-doc.patch"
		AT_M4DIR="${S}/macros" eautoreconf
	fi
}

src_configure() {
	# TODO: add other configure options
	# TODO: check use && use_with/use_enable statements
	econf \
		--with-gmp=/usr \
		--with-blas=/usr \
		--with-givaro=/usr \
		--enable-optimization \
		$(use ntl && use_with ntl) \
		$(use doc && use_enable doc) \
		$(use sage && use_enable sage) \
		|| die "econf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc ChangeLog README NEWS TODO

	if use doc ; then
		dohtml -r doc/linbox-html/*
	fi
}
