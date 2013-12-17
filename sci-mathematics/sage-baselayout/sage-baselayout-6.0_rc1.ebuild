# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

PYTHON_COMPAT=( python2_7 )

inherit eutils prefix python-r1 versionator

MY_P="sage_src-${PV}"

DESCRIPTION="Sage baselayout files"
HOMEPAGE="http://www.sagemath.org"
SRC_URI="mirror://sagemath/sage_src-${PV}.tar.bz2
	mirror://sagemath/patches/${PN}-6.0-r1-patch.tar.bz2
	mirror://sagemath/patches/sage-icon.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-macos"
IUSE="debug testsuite X tools"

RESTRICT="mirror"

DEPEND="
	!sci-mathematics/sage-extcode"
if  [[ ${CHOST} == *-darwin* ]] ; then
	RDEPEND="${DEPEND}
		tools? ( dev-vcs/mercurial )
		debug? ( sys-devel/gdb-apple )"
else
	RDEPEND="${DEPEND}
		tools? ( dev-vcs/mercurial )
		debug? ( sys-devel/gdb )"
fi

S="${WORKDIR}/${MY_P}/src/bin"
EXTSRC="${WORKDIR}/${MY_P}/src/ext"

# TODO: scripts into /usr/libexec ?
src_prepare() {
	# ship our own version of sage-env
	cp "${FILESDIR}"/proto.sage-env-6.0 "${S}"/sage-env
	eprefixify sage-env

	# make .desktop file
	cat > "${T}"/sage-sage.desktop <<-EOF
		[Desktop Entry]
		Name=Sage Shell
		Type=Application
		Comment=Math software for algebra, geometry, number theory, cryptography and numerical computation
		Exec=sage
		TryExec=sage
		Icon=sage
		Categories=Education;Science;Math;
		Terminal=true
	EOF

	# replace ${SAGE_ROOT}/local with ${SAGE_LOCAL}
	epatch "${WORKDIR}"/${PN}-5.9-fix-SAGE_LOCAL.patch
	eprefixify sage-notebook sage-notebook-insecure

	# solve sage-notebook start-up problems (after patching them)
	mv sage-notebook sage-notebook-real
	mv sage-notebook-insecure sage-notebook-insecure-real

	cat > sage-notebook <<-EOF
		#!/bin/bash

		source ${EPREFIX}/etc/sage-env
		${EPREFIX}/usr/bin/sage-notebook-real "\$@"
	EOF

	cat > sage-notebook-insecure <<-EOF
		#!/bin/bash

		source ${EPREFIX}/etc/sage-env
		${EPREFIX}/usr/bin/sage-notebook-insecure-real "\$@"
	EOF

	# TODO: if USE=debug/testsuite, remove corresponding options

	# replace MAKE by MAKEOPTS in sage-num-threads.py
	sed -i "s:os.environ\[\"MAKE\"\]:os.environ\[\"MAKEOPTS\"\]:g" \
		sage-num-threads.py

	# remove developer- and unsupported options
	epatch "${WORKDIR}"/sage-exec-6.0.patch
	eprefixify sage

	# create expected folders under extcode
	mkdir -p "${EXTSRC}"/sage
	mkdir -p "${EXTSRC}"/genus2reduction
}

src_install() {
	# TODO: patch sage-core and remove sage-native-execute ?

	# core scripts which are needed in every case
	python_foreach_impl python_doscript \
		sage-cleaner \
		sage-eval \
		sage-ipython \
		sage-run \
		sage-num-threads.py \
		sage-rst2txt \
		sage-rst2sws \
		sage-sws2rst
	dobin sage-maxima.lisp sage-native-execute
	dobin sage

	# install sage-env under /etc
	insinto /etc
	doins sage-env sage-banner

	if use testsuite ; then
		# DOCTESTING helper scripts
		python_foreach_impl python_doscript sage-runtests
	fi

	if use tools ; then
		# install some of sage tools for spkg development
		python_foreach_impl python_doscript sage-pkg
	fi

	# COMMAND helper scripts
	python_foreach_impl python_doscript \
		sage-cython \
		sage-notebook-insecure-real \
		sage-notebook-real \
		sage-run-cython
	dobin sage-notebook sage-notebook-insecure sage-python

	# additonal helper scripts
	python_foreach_impl python_doscript sage-preparse sage-startuptime.py

	if use debug ; then
		# GNU DEBUGGER helper schripts
		python_foreach_impl python_doscript sage-CSI
		insinto /usr/bin
		doins sage-CSI-helper.py sage-gdb-commands

		# VALGRIND helper scripts
		dobin sage-cachegrind sage-callgrind sage-massif sage-omega \
			sage-valgrind
	fi

	insinto /usr/share/sage
	doins ../../COPYING.txt

	insinto /etc
	doins "${FILESDIR}"/gprc.expect

	# install devel directories and link
	dodir /usr/share/sage/devel/sage-main
	dosym /usr/share/sage/devel/sage-main /usr/share/sage/devel/sage

	if use X ; then
		doicon "${WORKDIR}"/sage.svg
		domenu "${T}"/sage-sage.desktop
	fi

	cd "${EXTSRC}"
	insinto /usr/share/sage/ext
	doins -r *
}
