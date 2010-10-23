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
KEYWORDS="~amd64 ~ppc ~x86 ~amd64-linux ~x86-linux"
IUSE="+cxx cpudetection"

DEPEND="x86? ( dev-lang/yasm )
	amd64? ( dev-lang/yasm )"
RDEPEND=""

src_prepare(){
	epatch "${FILESDIR}/${PN}-1.3.0-yasm.patch"
	epatch "${FILESDIR}/${PN}-1.3.0-ABI-multilib.patch"
	# FIXME: In the same way there was QA regarding executable stacks
	#        with GMP we have some here as well. We cannot apply the
	#        GMP solution as yasm is used, at least on x86/amd64.
	#        Furthermore we are able to patch config.ac.
	eautoreconf
}

src_configure() {
# beware that cpudetection aka fat binaries is x86/amd64 only.
# Place mpir in profiles/arch/$arch/package.use.mask when making it available on $arch.
	econf \
		$(use_enable cxx) \
		$(use_enable cpudetection fat) \
		|| "econf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc ChangeLog README NEWS
}

pkg_postinst() {
	elog "The mpir ebuild is still under development."
	elog "Help us improve the ebuild in:"
	elog "http://bugs.gentoo.org/show_bug.cgi?id=293383"
	elog "This ebuild is known to have an executable stack problem"
}
