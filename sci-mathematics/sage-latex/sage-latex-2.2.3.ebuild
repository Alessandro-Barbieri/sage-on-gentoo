# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

SAGE_VERSION=4.3.2
SAGE_PACKAGE=sagetex-${PV}

inherit distutils latex-package sage

DESCRIPTION="LaTeX package for Sage"
# HOMEPAGE=""
# SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT="mirror"

# TODO: Check dependencies

DEPEND=">=dev-tex/tkz-berge-2.8"
RDEPEND="${DEPEND}"

# TODO: move examples to another directory ?
