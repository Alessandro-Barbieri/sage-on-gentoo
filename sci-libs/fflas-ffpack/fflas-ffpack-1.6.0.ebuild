# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit autotools-utils eutils toolchain-funcs

DESCRIPTION="FFLAS-FFPACK is a LGPL-2.1+ library for dense linear algebra over word-size finite fields."
HOMEPAGE="http://linalg.org/projects/fflas-ffpack"
SRC_URI="http://linalg.org/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-macos"
IUSE="static-libs"

RESTRICT="mirror"

DEPEND="virtual/cblas
	virtual/lapack
	>=dev-libs/gmp-4.0[cxx]
	~sci-libs/givaro-3.7.0"
RDEPEND="${DEPEND}"

AUTOTOOLS_AUTORECONF="1"
PATCHES=(
	"${FILESDIR}/${P}-blaslapack.patch"
	)
