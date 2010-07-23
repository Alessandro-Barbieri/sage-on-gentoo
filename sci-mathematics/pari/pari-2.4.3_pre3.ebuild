# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
inherit elisp-common eutils flag-o-matic toolchain-funcs

DESCRIPTION="A software package for computer-aided number theory"
HOMEPAGE="http://pari.math.u-bordeaux.fr/"

SRC_COM="http://pari.math.u-bordeaux.fr/pub/${PN}"
SRC_URI="http://www.warwick.ac.uk/staff/J.E.Cremona/pari-2.4.3.svn.p5.spkg -> ${P}.tar.bz2
	data? (	${SRC_COM}/packages/elldata.tgz
			${SRC_COM}/packages/galdata.tgz
			${SRC_COM}/packages/seadata.tgz
			${SRC_COM}/packages/nftables.tgz )"

LICENSE="GPL-2"
SLOT="3"
KEYWORDS="~alpha ~amd64 ~hppa ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="doc data fltk gmp X"
RESTRICT="mirror"

RDEPEND="sys-libs/readline
	fltk? ( x11-libs/fltk )
	gmp? ( dev-libs/gmp )
	X? ( x11-libs/libX11 )
	doc? ( X? ( x11-misc/xdg-utils ) )"
DEPEND="${RDEPEND}
	doc? ( virtual/latex-base )"

S="${WORKDIR}/pari-2.4.3.svn.p5/src"

get_compile_dir() {
	pushd "${S}/config" >& /dev/null
	local fastread=yes
	source ./get_archos
	popd >& /dev/null
	echo "O${osname}-${arch}"
}

src_prepare() {
	# remove data shipped with sage's svn snapshot of pari
	rm -rf data/*
	# move data into place
	if use data; then
		mv "${WORKDIR}"/data "${S}" || die "failed to move data"
	fi
	epatch "${FILESDIR}/${PN}"-2.3.2-strip.patch
	epatch "${FILESDIR}/${PN}"-2.3.2-ppc-powerpc-arch-fix.patch
	epatch "${FILESDIR}/${P}"-errhandling.patch

	# disable default building of docs during install
	sed -i \
		-e "s:install-doc install-examples:install-examples:" \
		config/Makefile.SH || die "Failed to fix makefile"
	# propagate ldflags
	sed -i \
		-e 's/-shared $extra/-shared $extra \\$(LDFLAGS)/' \
		config/get_dlld || die "Failed to fix LDFLAGS"
	# move doc dir to a gentoo doc dir and replace hardcoded xdvi by xdg-open
	sed -i \
		-e "s:\$d = \$0:\$d = '/usr/share/doc/${PF}':" \
		-e 's:"xdvi":"xdg-open":' \
		-e 's:xdvi -paper 29.7x21cm:xdg-open:' \
		doc/gphelp.in || die "Failed to fix doc dir"

	# fix gp compilation - thanks dilfridge for the syntax.
	# slot everything, remove tex2mail to avoid clash with 2.3
	epatch "${FILESDIR}/${P}"-MakefileSH.patch
	sed -i "s:-lpari:-lpari24:" Configure || die "Failed to slot in Configure"
}

src_configure() {
	tc-export CC
	# need to force optimization here, as it breaks without
	if   is-flag -O0; then
		replace-flags -O0 -O2
	elif ! is-flag -O?; then
		append-flags -O2
	fi
	# sysdatadir installs a pari.cfg stuff which is informative only
	./Configure \
		--prefix=${EPREFIX}/usr \
		--datadir=${EPREFIX}/usr/share/${PF} \
		--libdir=${EPREFIX}/usr/$(get_libdir) \
		--sysdatadir=${EPREFIX}/usr/share/doc/${PF} \
		--mandir=${EPREFIX}/usr/share/man/man1 \
		--with-readline \
		$(use_with gmp) \
		|| die "./Configure failed"
}

src_compile() {
	if use hppa; then
		mymake=DLLD\=${EPREFIX}/usr/bin/gcc\ DLLDFLAGS\=-shared\ -Wl,-soname=\$\(LIBPARI_SONAME\)\ -lm
	fi

	local installdir=$(get_compile_dir)
	cd "${installdir}" || die "Bad directory"

	# upstream set -fno-strict-aliasing.
	# aliasing is a known issue on amd64, it probably work on x86 by sheer luuck.
	emake ${mymake} CFLAGS="${CFLAGS} -fno-strict-aliasing -DGCC_INLINE -fPIC" lib-dyn \
		|| die "Building shared library failed!"

#	if use static; then
#		emake ${mymake} CFLAGS="${CFLAGS} -DGCC_INLINE" lib-sta \
#			|| die "Building static library failed!"
#	fi

	emake ${mymake} CFLAGS="${CFLAGS} -DGCC_INLINE" gp ../gp \
		|| die "Building executables failed!"

	if use doc; then
		cd "${S}"
		# To prevent sandbox violations by metafont
		VARTEXFONTS="${T}"/fonts emake docpdf \
			|| die "Failed to generate docs"
	fi
}

src_test() {
	emake test-kernel || die
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"

	dodoc AUTHORS Announce.2.1 CHANGES README NEW MACHINES COMPAT
	if use doc; then
		emake \
			DESTDIR="${ED}" \
			EXDIR="${ED}/usr/share/doc/${PF}/examples" \
			DOCDIR="${ED}/usr/share/doc/${PF}" \
			install-doc || die "Failed to install docs"
		insinto /usr/share/doc/${PF}
		doins doc/*.pdf || die "Failed to install pdf docs"
	fi

	if use data; then
		emake DESTDIR="${D}" install-data || die "Failed to install data files"
	fi
}

pkg_postinst(){
	ewarn "This version of pari is a svn snapshot used in the sage project."
	ewarn "It is installed in its own slot, so you can use the stable pari in parallel."
	ewarn "The default pari is the stable one, if you want to use this version of pari"
	ewarn "you have to explicitly require it."
	ewarn "The executable is gp-2.4, gp is a reserved link for pari-2.3.xx."
	ewarn "The headers are in /usr/include/pari24 not /usr/include/pari which should hold pari-2.3.xx headers."
	ewarn "To use the library you need to link with -lpari24."
	ewarn "emacs installation has changed and is not included here, if you want to help with that send us a line."
}