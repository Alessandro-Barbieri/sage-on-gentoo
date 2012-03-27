# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

PYTHON_DEPEND="2:2.7:2.7"
PYTHON_USE_WITH="readline sage sqlite"

inherit distutils eutils flag-o-matic python versionator

MY_P="sage-$(replace_version_separator 2 '.')"

DESCRIPTION="Math software for algebra, geometry, number theory, cryptography and numerical computation"
HOMEPAGE="http://www.sagemath.org"
SRC_URI="http://sage.math.washington.edu/home/release/${MY_P}/${MY_P}/spkg/standard/${MY_P}.spkg -> ${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux ~x86-macos"
IUSE="mpc latex testsuite"

RESTRICT="mirror test"

CDEPEND="dev-libs/gmp
	>=dev-libs/mpfr-3.1.0
	>=dev-libs/ntl-5.5.2
	>=dev-libs/ppl-0.11.2
	>=dev-lisp/ecls-11.1.1-r1[-unicode]
	~dev-python/numpy-1.5.1
	>=sci-mathematics/eclib-20100711[-pari24]
	>=sci-mathematics/ecm-6.2.1
	>=sci-libs/flint-1.5.0[ntl]
	>=sci-libs/fplll-3.0.12
	=sci-libs/givaro-3.2*
	>=sci-libs/gsl-1.15
	>=sci-libs/iml-1.0.1
	>=sci-libs/libcliquer-1.2_p7
	>=sci-libs/linbox-1.1.6-r5[sage]
	!=sci-libs/linbox-1.1.7
	~sci-libs/m4ri-20111004
	~sci-libs/m4rie-20111004
	>=sci-libs/mpfi-1.5
	=sci-libs/pynac-0.2.3
	>=sci-libs/symmetrica-2.0
	>=sci-libs/zn_poly-0.9
	>=sci-mathematics/glpk-4.43
	>=sci-mathematics/lcalc-1.23-r4[pari]
	>=sci-mathematics/pari-2.5.1[data,gmp]
	~sci-mathematics/polybori-0.8.1
	>=sci-mathematics/ratpoints-2.1.3
	~sci-mathematics/sage-baselayout-${PV}[testsuite=]
	~sci-mathematics/sage-clib-${PV}
	~sci-libs/libsingular-3.1.3.3
	media-libs/gd[jpeg,png]
	media-libs/libpng
	>=sys-libs/readline-6.2
	sys-libs/zlib
	virtual/cblas
	mpc? ( dev-libs/mpc )"

DEPEND="${CDEPEND}
	=dev-python/cython-0.15.1"

RDEPEND="${CDEPEND}
	>=dev-lang/R-2.14.0
	>=dev-python/cvxopt-1.1.3[glpk]
	>=dev-python/gdmodule-0.56-r2[png]
	~dev-python/ipython-0.10.2
	>=dev-python/jinja-2.1.1
	>=dev-python/matplotlib-1.1.0
	>=dev-python/mpmath-0.16
	~dev-python/networkx-1.2
	~dev-python/pexpect-2.0
	>=dev-python/pycrypto-2.1.0
	>=dev-python/rpy-2.0.6
	>=dev-python/sphinx-1.1.2
	dev-python/sqlalchemy
	~dev-python/sympy-0.7.1
	>=media-gfx/tachyon-0.98[png]
	net-zope/zodb
	>=sci-libs/cddlib-094f-r2
	>=sci-libs/scipy-0.9
	>=sci-mathematics/flintqs-20070817_p5
	>=sci-mathematics/gap-4.4.12
	>=sci-mathematics/genus2reduction-0.3_p8-r1
	~sci-mathematics/gfan-0.5
	>=sci-mathematics/cu2-20060223
	>=sci-mathematics/cubex-20060128
	>=sci-mathematics/dikcube-20070912_p12
	>=sci-mathematics/maxima-5.26.0[ecls]
	>=sci-mathematics/mcube-20051209
	>=sci-mathematics/optimal-20040603
	>=sci-mathematics/palp-2.0
	~sci-mathematics/sage-data-conway_polynomials-0.2
	~sci-mathematics/sage-data-elliptic_curves-0.5
	~sci-mathematics/sage-data-graphs-20070722_p2
	~sci-mathematics/sage-data-polytopes_db-20100210_p1
	>=sci-mathematics/sage-doc-${PV}
	~sci-mathematics/sage-extcode-${PV}
	~sci-mathematics/singular-3.1.3.3
	>=sci-mathematics/sympow-1.018.1_p8-r1[-pari24]
	!prefix? ( >=sys-libs/glibc-2.13-r4 )
	testsuite? ( ~sci-mathematics/sage-doc-${PV}[html] )
	latex? (
		~dev-tex/sage-latex-2.3.1
		|| (
			app-text/dvipng[truetype]
			media-gfx/imagemagick[png]
		)
	)"

PDEPEND="~sci-mathematics/sage-notebook-0.8.27"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	# TODO: put the following check into pkg_pretend once we may use EAPI 4 with
	# the python eclass
	if ( eselect blas show ; eselect lapack show ) | grep -q "atlas" ; then

	ewarn "You are about to compile Sage with ATLAS blas/lapack libraries. We"
	ewarn "discourage the use of atlas because of several small problems seen"
	ewarn "with version 3.9.23+ in Sage's doctests. This is probably not a"
	ewarn "problem for everyday use of Sage but we have warned you!"

	fi

	# Sage now will only works with python 2.7.*
	python_set_active_version 2.7
	python_pkg_setup
}

src_prepare() {
	# ATLAS independence
	local cblaslibs=\'$(pkg-config --libs-only-l cblas | sed \
		-e 's/^-l//' \
		-e "s/ -l/\',\'/g" \
		-e 's/.,.pthread//g' \
		-e "s:  ::")\'

	# patch to module_list.py because of trac 4539
	epatch "${FILESDIR}"/${PN}-5.0-plural.patch

	# make sure we use cython-2.7 for consistency
	sed -i "s:python \`which cython\`:cython-2.7:" setup.py

	############################################################################
	# Fixes to Sage's build system
	############################################################################

	# Fix startup issue and python-2.6.5 problem
	append-flags -fno-strict-aliasing

	epatch "${FILESDIR}"/${PN}-4.7.2-site-packages.patch

	# add pari and gmp to everything.
	sed -i "s:\['stdc++', 'ntl'\]:\['stdc++', 'ntl','pari','gmp'\]:g" setup.py

	sed -e "s:%s/local/etc/gprc.expect'%SAGE_ROOT:${EPREFIX}/etc/gprc.expect':" \
		-i sage/interfaces/gp.py

	# use already installed csage
	rm -rf c_lib || die "failed to remove c library directory"

	# patch SAGE_LOCAL
	sed -i "s:SAGE_LOCAL = SAGE_ROOT + '/local':SAGE_LOCAL = os.environ['SAGE_LOCAL']:g" \
		setup.py
	sed -i "s:SAGE_LOCAL = SAGE_ROOT + '/local':SAGE_LOCAL = os.environ['SAGE_LOCAL']:g" \
		module_list.py

	sed -i "s:'%s/sage/sage/ext'%SAGE_DEVEL:'sage/ext':g" \
		setup.py

	# fix misc/dist.py
	epatch "${FILESDIR}"/${PN}-4.8-dist.py.patch

	# fix png library name
	sed -i "s:png12:$(libpng-config --libs | cut -dl -f2):g" \
		module_list.py

	# fix numpy path (final quote removed to catch numpy_include_dirs and numpy_depends)
	sed -i "s:SAGE_LOCAL + '/lib/python/site-packages/numpy/core/include:'${EPREFIX}$(python_get_sitedir)/numpy/core/include:g" \
		module_list.py

	# fix cython path
	sed -i \
		-e "s:SAGE_LOCAL + '/lib/python/site-packages/Cython/Includes/':'${EPREFIX}$(python_get_sitedir)/Cython/Includes/':g" \
		-e "s:SAGE_LOCAL + '/lib/python/site-packages/Cython/Includes/Deprecated/':'${EPREFIX}$(python_get_sitedir)/Cython/Includes/Deprecated/':g" \
		setup.py

	# fix lcalc path
	sed -i "s:SAGE_INC + \"lcalc:SAGE_INC + \"Lfunction:g" module_list.py

	# rebuild in place
	sed -i "s:SAGE_DEVEL + '/sage/sage/ext/interpreters':'sage/ext/interpreters':g" \
		setup.py

	# fix include paths and CBLAS/ATLAS
	sed -i \
		-e "s:'%s/include/csage'%SAGE_LOCAL:'${EPREFIX}/usr/include/csage':g" \
		-e "s:'%s/sage/sage/ext'%SAGE_DEVEL:'sage/ext':g" \
		setup.py

	sed -i \
		-e "s:BLAS, BLAS2:${cblaslibs}:g" \
		-e "s:,BLAS:,${cblaslibs}:g" \
		module_list.py

	# Add -DNDEBUG to objects linking to libsingular and use factory headers from singular.
	sed -i "s:SAGE_INC + 'singular'\],:SAGE_INC + 'singular'\],extra_compile_args = \['-DNDEBUG'\],:g" \
		module_list.py
	sed -i "s:'singular', SAGE_INC + 'factory'\],:'singular'\],extra_compile_args = \['-DNDEBUG'\],:g" \
		module_list.py

	# TODO: why does Sage fail with linbox commentator ?

	############################################################################
	# Fixes to Sage itself
	############################################################################

	# fix the location of that blasted sagestarted.txt file, trac 11926 (11926_sage.patch)
	epatch "${FILESDIR}"/${PN}-4.8-sagestarted.patch

	# issue 85 a test crashes earlier than vanilla
	sed -i "s|sage: x = dlx_solver(rows)|sage: x = dlx_solver(rows) # not tested|" \
		sage/combinat/tiling.py

	# update to gfan-0.5 (breaks test) trac 11395)
	epatch "${FILESDIR}"/${PN}-4.6.2-gfan-0.5.patch

	# patch for jmol-12.0.45
	epatch "${FILESDIR}"/trac_9238_script_extension.patch

	# fix some cython warnings
	epatch "${FILESDIR}"/trac_10764-fix_deprecation_warning.patch
	epatch "${FILESDIR}"/trac_10764-fix-gen_interpreters_doctest.patch

	# run maxima with ecl
	sed -i \
		-e "s:maxima-noreadline:maxima -l ecl:g" \
		sage/interfaces/maxima.py
	sed -i \
		-e "s:maxima --very-quiet:maxima -l ecl --very-quiet:g" \
		sage/interfaces/maxima_abstract.py

	# Uses singular internal copy of the factory header
	sed -i "s:factory/factory.h:singular/factory.h:" sage/libs/singular/singular-cdefs.pxi

	# Fix portage QA warning. Potentially prevent some leaking.
	epatch "${FILESDIR}"/${PN}-4.4.2-flint.patch

	sed -i "s:cblas(), atlas():${cblaslibs}:" sage/misc/cython.py

	# patch for glpk
	sed -i \
		-e "s:\.\./\.\./\.\./\.\./devel/sage/sage:..:g" \
		-e "s:\.\./\.\./\.\./local/include/::g" \
		sage/numerical/backends/glpk_backend.pxd

	# Ticket #5155:

	# save gap_stamp to directory where sage is able to write
	sed -i "s:GAP_STAMP = '%s/local/bin/gap_stamp'%SAGE_ROOT:GAP_STAMP = '%s/gap_stamp'%DOT_SAGE:g" \
		sage/interfaces/gap.py

	# fix qepcad paths
	epatch "${FILESDIR}"/${PN}-4.5.1-fix-qepcad-path.patch

	# replace SAGE_ROOT/local with SAGE_LOCAL
	epatch "${FILESDIR}"/${PN}-5.0-fix-SAGE_LOCAL.patch

	# patch path for saving sessions
	sed -i "s:save_session('tmp_f', :save_session(tmp_f, :g" \
		sage/misc/session.pyx

	# patch lie library path
	sed -i "s:open(SAGE_LOCAL + 'lib/lie/INFO\.0'):open(SAGE_LOCAL + '/share/lie/INFO.0'):g" \
		sage/interfaces/lie.py

	# Patch to singular info file shipped with sage-doc
	sed -i "s:os.environ\[\"SAGE_LOCAL\"\]+\"/share/singular/\":os.environ\[\"SAGE_DOC\"\]+\"/\":g" \
		sage/interfaces/singular.py

	# fix the cmdline test using SAGE_ROOT
	sed -i "s:SAGE_ROOT, \"local\":os.environ[\"SAGE_LOCAL\"]:" \
		sage/tests/cmdline.py

	# enable dev-libs/mpc if required
	if use mpc ; then
		sed -i "s:is_package_installed('mpc'):True:g" module_list.py
	fi

	# fix all paths using SAGE_ROOT or other
	# polymake
	sed -i "s:%s/local/polymake/bin/'%os.environ\['SAGE_ROOT'\]:%/bin/'%os.environ\['SAGE_LOCAL'\]:" \
		sage/geometry/polytope.py
	# kash-bin documentation
	sed -i "s:%s/local/lib/kash/html\"%os.environ\['SAGE_ROOT'\]:${EPREFIX}/opt/kash3/html:" \
		sage/interfaces/kash.py
	# sandpile.py
	sed \
		-e "s:SAGE_ROOT+'/local/bin/':SAGE_LOCAL+'/bin':g" \
		-e "s:SAGE_ROOT = os.environ\['SAGE_ROOT'\]:SAGE_LOCAL = os.environ\['SAGE_LOCAL'\]:" \
		-i sage/sandpiles/sandpile.py

	# apply patches from /etc/portage/patches
	epatch_user

	# do not forget to run distutils
	distutils_src_prepare
}

src_configure() {
	export SAGE_LOCAL="${EPREFIX}"/usr/
	export SAGE_ROOT="${EPREFIX}"/usr/share/sage
	export SAGE_VERSION=${PV}
	export DOT_SAGE="${S}"

	local sage_num_threads_array=(
		$(sage-num-threads.py 2>/dev/null || echo 1 2 1)
	)
	export SAGE_NUM_THREADS=${sage_num_threads_array[0]}

	# files are not built unless they are touched
	find sage -name "*pyx" -exec touch '{}' \; \
		|| die "failed to touch *pyx files"
}

src_install() {
	distutils_src_install

	if use testsuite ; then
		# install testable sources and sources needed for testing
		find sage ! \( -name "*.py" -o -name "*.pyx" -o -name "*.pxd" -o \
			-name "*.pxi" -o -name "*.h" \
			-o -name "*fmpq_poly.c" \
			-o -name "*matrix_rational_dense_linbox.cpp" \
			-o -name "*wrap.cc" \) -type f -delete \
			|| die "failed to remove non-testable sources"

		insinto /usr/share/sage/devel/sage-main
		doins -r sage || die
	fi
}

pkg_postinst() {
	einfo "If you use Sage's browser interface ('Sage Notebook') and experience"
	einfo "an 'Internal Server Error' you should append the following line to"
	einfo "your ~/.bashrc (replace firefox with your favorite browser and note"
	einfo "that in your case it WILL NOT WORK with xdg-open):"
	einfo ""
	einfo "  export SAGE_BROWSER=/usr/bin/firefox"
	einfo ""

	einfo "Vanilla Sage comes with the 'Standard' set of Sage Packages, i.e."
	einfo "those listed at: http://sagemath.org/packages/standard/ which are"
	einfo "installed now."
	einfo "There are also some packages of the 'Optional' set (which consists"
	einfo "of the these: http://sagemath.org/packages/optional/) available"
	einfo "which may be installed with portage as usual."

	if use testsuite ; then

	einfo ""
	einfo "You have installed Sage's testsuite. In order to test Sage run the"
	einfo "following command in a directory where Sage may write to, e.g.:"
	einfo ""
	einfo "  cd \$(mktemp -d) && sage -testall"
	einfo ""
	einfo "After testing has finished, NO FILES SHOULD BE LEFT in this"
	einfo "directory. If this is not the case, please send us a bug report."
	einfo "Parallel doctesting is also possible (replace '8' with an adequate"
	einfo "number of processes):"
	einfo ""
	einfo "  cd \$(mktemp -d) && sage -tp 8 -sagenb \\"
	einfo "      ${EPREFIX}/usr/share/sage/devel/sage-main/"
	einfo ""
	einfo "Note that testing Sage may take more than 4 hours. If you want to"
	einfo "check your results look at the list of known failures:"
	einfo ""
	einfo "  http://github.com/cschwan/sage-on-gentoo/wiki/Known-test-failures"

	fi
}
