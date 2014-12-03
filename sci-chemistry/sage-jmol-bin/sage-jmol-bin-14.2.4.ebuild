# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit java-pkg-2

MY_PN="jmol"
MY_P=${MY_PN}-${PV}_2014.08.03
DESCRIPTION="Jmol is a java molecular viever for 3-D chemical structures."
HOMEPAGE="http://jmol.sourceforge.net/"
SRC_URI="mirror://sageupstream/${MY_PN}/${MY_P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
iUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	>=virtual/jre-1.7"

QA_PREBUILT="*"

S="${WORKDIR}"/${MY_P}

src_prepare(){
	rm jmol.bat jmol.mac
}

src_compile() { :; }

src_install() {
	dodoc *.txt || die

	java-pkg_dojar *.jar
	java-pkg_dolauncher ${MY_PN} --main org.openscience.jmol.app.Jmol \
		--java_args "-Xmx512m"
	insinto /usr/share/${PN}/lib/jsmol
	doins -r jsmol/*
}