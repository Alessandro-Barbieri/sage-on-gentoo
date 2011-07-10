# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

PYTHON_DEPEND="2:2.7"

inherit eutils flag-o-matic multilib python scons-utils toolchain-funcs mercurial

DESCRIPTION="Polynomials over Boolean Rings"
HOMEPAGE="http://polybori.sourceforge.net/"
#SRC_URI="mirror://sourceforge/${PN}/${PN}/${PV}/${P}.tar.gz"
EHG_REPO_URI="https://bitbucket.org/brickenstein/polybori"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="doc gd sage"

# polybori does not have a working set of tests
RESTRICT="mirror test"

CDEPEND=">=dev-libs/boost-1.34.1[python]
	dev-python/ipython
	gd? ( media-libs/gd )"
DEPEND="${CDEPEND}
	>=sci-libs/m4ri-20090512
	doc? (
		dev-tex/tex4ht
		app-doc/doxygen
	)"
RDEPEND="${CDEPEND}"

USE_SCONS_TRUE="True"
USE_SCONS_FALSE="False"

pkg_setup() {
	python_set_active_version 2.7
	python_pkg_setup

	if use sage ; then
		export DOT_SAGE="${S}"
	fi

	ewarn "This version of polybori is not compatible with any current release of sage"
	ewarn "It is only provided to ease testing for future release"
	ewarn "see http://trac.sagemath.org/sage_trac/ticket/11575 for current 0.8 plans"
}

src_prepare() {
	if use sage ; then
		# TODO: This should not be done; find a better solution
		cp "${FILESDIR}"/PyPolyBoRi.py pyroot/polybori/PyPolyBoRi.py \
			|| die "cp failed"
	fi

	# make sure external m4ri is used
	rm -r M4RI || die "failed to remove internal copy of m4ri"

	# make polybori conform to multilib-strict
	sed -i "s:DevelInstPath('lib'):DevelInstPath('$(get_libdir)'):g" \
		SConstruct || die "failed patch library path"

	# remove automatic -O3
	epatch "${FILESDIR}"/${PN}-0.8-SConstruct_O3.patch
}

src_compile(){
	# needed to make polybori linkable
	#append-flags -fPIC

	if [[ ${CHOST} == *-darwin* ]] ; then
		append-flags -fno-strict-aliasing
	fi

	# TODO: handle singular ?

	# store all parameters for scons in a bash array
	myesconsargs=(
		CC=$(tc-getCC)
		CXX=$(tc-getCXX)
		CFLAGS=${CFLAGS}
		CXXFLAGS=${CXXFLAGS}
		LINKFLAGS=${LDFLAGS}
		HAVE_HEVEA=False
		HAVE_L2H=False
		$(use_scons doc HAVE_TEX4HT)
		$(use_scons doc HAVE_DOXYGEN)
		$(use_scons doc HAVE_PYDOC)
		MANDIR="${ED}"/usr/share/man
		PREFIX="${ED}"/usr
		PYINSTALLPREFIX="${ED}"$(python_get_sitedir)
		INSTALLDIR="${ED}"/usr/share/polybori
		CONFFILE="${ED}"/usr/share/polybori/flags.conf
	)

	# extra configuration for macos
	# FIXME: don't know how to deal properly with versionned libraries with install_name so dropping it.
	if [[ ${CHOST} == *-darwin* ]] ; then
		myesconsargs+=(
			FORCE_HASH_MAP=True
			SHLINKFLAGS="${LDFLAGS} -dynamiclib"
			HAVE_PYTHON_EXTENSION=False
			EXTERNAL_PYTHON_EXTENSION=True
			SHLIBVERSIONING=False
		)
	fi

	escons "${myesconsargs[@]}" prepare-install prepare-devel || die
}

src_install() {
	escons "${myesconsargs[@]}" install devel-install || die

	# remove incomplete documentation
	if ! use doc ; then
		rm -rf "${ED}"/usr/share/polybori/doc \
			|| die "failed to remove useless documentation"
	fi

	# we only need shared objects elsewhere
	#rm "${ED}"/usr/$(get_libdir)/lib*.a \
	#	|| die "failed to remove static libraries"

	# fixing flags.conf
	sed -i "s:${D}:\/:" "${ED}"/usr/share/polybori/flags.conf || die

	# FIXME: Dynamic libraries now work on linux but are broken on OS X
	if [[ ${CHOST} == *-darwin* ]] ; then
		# Removing dynamic libraries keeping only static objects
		rm "${ED}"/usr/$(get_libdir)/lib*.dylib \
			|| die "failed to remove static libraries"
	else
		# we only need shared objects elsewhere
		rm "${ED}"/usr/$(get_libdir)/lib*.a \
		|| die "failed to remove static libraries"
	fi

	# fixing install names on OS X
	#if [[ ${CHOST} == *-darwin* ]] ; then
	#	cd "${ED}"/usr/$(get_libdir)
	#	for d in *.dylib ; do
	#		ebegin "  correcting install_name of ${d}"
	#		install_name_tool -id "${EPREFIX}/usr/$(get_libdir)/${d}" "${d}"
	#		eend $?
	#	done
	#fi
	# fixing install names on OS X
}
