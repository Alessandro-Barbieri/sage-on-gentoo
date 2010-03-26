# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

MY_P="${P}.1.p6"

# TODO: Is Sage now upstream ? Homepage below does not work

DESCRIPTION="Computes special values of symmetric power elliptic curve L-functions"
# HOMEPAGE="http://www.maths.bris.ac.uk/%7Emamjw/"
SRC_URI="mirror://sage/spkg/standard/${MY_P}.spkg -> ${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

RESTRICT="mirror"

DEPEND=""
RDEPEND="sci-mathematics/pari"

S="${WORKDIR}/${MY_P}/src"

src_prepare() {
	# sympow assumes its datafiles in the directory it is invoked from - fix it
	sed -i "s:datafiles/:/var/lib/sympow/datafiles/:g" disk.c generate.c *.gp \
		|| die "sed failed"
	sed -i "s:cd datafiles:cd /var/lib/sympow/datafiles:g" generate.c \
		|| die "sed failed"

	# also fix paths of gp scripts
	sed -i \
		-e "s:standard1.gp:/usr/share/sympow/standard1.gp:g" \
		-e "s:standard2.gp:/usr/share/sympow/standard2.gp:g" \
		-e "s:standard3.gp:/usr/share/sympow/standard3.gp:g" generate.c \
		|| die "sed failed"

	# fix calls to itself - this one first:
	sed -i -e "s:\.\./sympow:sympow:g" generate.c || die "sed failed"

	# now this:
	sed -i -e "s:\./sympow:sympow:g" disk.c new_data README || die "sed failed"

	# rename script to avoid possible file conflicts
	sed -i "s:\"new_data\":\"/usr/bin/sympow_new_data\":g" generate.c \
		|| die "sed failed"

	# fix hardcoded string lengths (still hardcoded, but respects new path)
	sed -i "s:int dl=9;:int dl=9+16;:g" disk.c || die "sed failed"

	# make arrays larger because pathnames are now longer
	sed -i "s:char NM\[32\],NAME\[32\]:char NM[128],NAME[128]:g" disk.c \
		|| die "sed failed"

	# rename script
	mv new_data sympow_new_data
}

src_configure() {
	./Configure || die "Configure failed"
}

src_compile() {
	emake || die "make failed"
}

# TODO: cleanup localstatedir=/var/lib/sympow in pkg_postrm ?
src_install() {
	# install binary and script
	dobin sympow sympow_new_data || die "dobin failed"

	# install pari scripts
	insinto /usr/share/sympow
	doins *.gp || die "doins failed"

	# install writable data
	insinto /var/lib/sympow
	doins -r datafiles || die "doins failed"

	# TODO: QA - find less crude permissions
	# sympow needs write access to this directory
	fperms a+w -R /var/lib/sympow || die "fperms failed"

	# install docs
	dodoc README || die "dodoc failed"
}
