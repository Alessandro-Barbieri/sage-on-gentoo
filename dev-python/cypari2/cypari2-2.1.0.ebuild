# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_{5,6,7} )
inherit distutils-r1

DESCRIPTION="A Python interface to the number theory library libpari"
HOMEPAGE="https://github.com/sagemath/cypari2"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=sci-mathematics/pari-2.10.0_pre20170914:=[gmp,doc]
	>=dev-python/cython-0.28
	dev-python/cysignals"
RDEPEND="${DEPEND}"

python_test(){
	cd "${S}"/tests
	${EPYTHON} rundoctest.py
}
