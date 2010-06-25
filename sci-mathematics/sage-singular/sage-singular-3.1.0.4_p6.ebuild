# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit eutils flag-o-matic multilib versionator sage

MY_P="singular-$(replace_version_separator 4 '.')"

DESCRIPTION="Sage's version of singular: Computer algebra system for polynomial computations"
# TODO Splitting the ebuild to build libsingular separately to enforce correct pic-ness.
HOMEPAGE="http://www.singular.uni-kl.de/"
SRC_URI="mirror://sage/spkg/standard/${MY_P}.spkg -> ${P}.tar.bz2"
#### Remove the following line when moving this ebuild to the main tree!
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~ppc"
IUSE=""

RDEPEND=">=dev-libs/gmp-4.1-r1
	>=dev-libs/ntl-5.5.1"

DEPEND="${RDEPEND}
	>=dev-lang/perl-5.6"

S="${WORKDIR}/${MY_P}/src"

append-flags -fPIC

src_prepare () {
	cp ../patches/mminit.cc kernel/
	cp ../patches/assert.h factory/
	cp ../patches/kernel.rmodulon.cc kernel/rmodulon.cc
	cp ../patches/src.Singular.Makefile.in Singular/Makefile.in
	cp ../patches/Singular.libsingular.h Singular/libsingular.h
	cp ../patches/factory.GNUmakefile.in factory/GNUmakefile.in
	cp ../patches/libfac.charset.alg_factor.cc libfac/charset/alg_factor.cc
	cp ../patches/kernel.Makefile.in kernel/Makefile.in
	cp ../patches/Singular.Makefile.in Singular/Makefile.in
	cp ../patches/Singular.tesths.cc Singular/tesths.cc

	sed -i "s:@INSTALL_PROGRAM@  -s:@INSTALL_PROGRAM@:g" IntegerProgramming/Makefile.in

	mkdir -p build
}

src_configure() {
	econf --prefix="${S}"/build \
		--exec-prefix="${S}"/build \
		--bindir="${S}"/build/bin \
		--libdir="${S}"/build/lib \
		--libexecdir="${S}"/build/lib \
		--with-apint=gmp \
		--with-gmp=/usr \
		--with-NTL \
		--with-ntl=/usr \
		--without-MP \
		--without-lex \
		--without-bison \
		--without-Boost \
		--enable-Singular \
		--enable-IntegerProgramming \
		--enable-factory \
		--enable-libfac \
		--disable-doc \
		--with-malloc=system || die "econf failed"
}

src_compile() {
	emake -j1 || die "make failed"
	emake slibdir="${S}/build/share/singular" install-nolns || die "install-nolns failed"
	emake -j1 libsingular || "emake libsingular failed"
	emake -j1 install-libsingular || die "emake install-libsingular failed"
}

src_install(){
#	Not making the link LIB to lib since it seems to be incorrect in the first place.
	rm build/bin/Singular
	rm build/LIB

	into "${SAGE_LOCAL}"
	dobin build/bin/*
	dobin "${FILESDIR}"/singular
	newbin "${FILESDIR}"/singular Singular
	dosym Singular "${SAGE_LOCAL}"/bin/sage_singular

	dolib build/lib/*.so build/lib/*.a build/lib/*.o

	insinto "${SAGE_LOCAL}"/share
	doins -r build/share/*
	insinto "${SAGE_LOCAL}"/share/singular
	doins "${S}"/../shared/singular.hlp "${S}"/../shared/singular.idx

	insinto "${SAGE_LOCAL}"/include
	doins -r build/include/*
#	Beware that when we move stuff in /usr we should make sure
#	that we call singular's binaries in $SAGE_LOCAL.
}
