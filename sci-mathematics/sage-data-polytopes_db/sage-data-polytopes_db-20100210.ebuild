# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

MY_PN="polytopes_db"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Sage's polytopes database"
HOMEPAGE="http://www.sagemath.org"
SRC_URI="mirror://sagemath/${MY_PN}/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-macos"
IUSE=""

RESTRICT="mirror"

DEPEND=""
RDEPEND=""

S="${WORKDIR}"/${MY_P}

src_install() {
	insinto /usr/share/sage/reflexive_polytopes
	doins *
}