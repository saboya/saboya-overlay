# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5} )
PYTHON_REQ_USE="threads(+)"

inherit distutils-r1

DESCRIPTION="A self-contained cryptographic library for Python"
HOMEPAGE="https://github.com/Legrandin/pycryptodome"
SRC_URI="https://github.com/Legrandin/${PN}/archive/v${PV}.tar.gz"

LICENSE="PSF-2 public-domain"
SLOT="0"
KEYWORDS="alpha amd64 arm ~arm64 hppa ia64 ~m68k ~mips ppc ppc64 ~s390 ~sh sparc x86 ~ppc-aix ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~ia64-hpux ~x86-interix ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~x86-solaris"
IUSE="doc +gmp +namespaced"

RDEPEND="gmp? ( dev-libs/gmp:0= )"
DEPEND="${RDEPEND}
	!namespaced? ( !dev-python/pycrypto )
	doc? ( dev-python/docutils
		>=dev-python/epydoc-3 )"

python_configure_all() {
	if use namespaced; then
		touch ${WORKDIR}/${P}/.separate_namespace
	fi

	# Bug in setup.py: https://github.com/Legrandin/pycryptodome/issues/22
	mkdir -p ${WORKDIR}/${P}/build
}

python_compile_all() {
	if use doc; then
		rst2html.py Doc/index.rst > Doc/index.html
		epydoc --config=Doc/epydoc-config --exclude-introspect="^Crypto\.(Random\.OSRNG\.nt|Util\.winrandom)$" || die
	fi
}

python_compile() {
	python_is_python3 || local -x CFLAGS="${CFLAGS} -fno-strict-aliasing"
	esetup.py build_ext
	distutils-r1_python_compile
}

python_test() {
	esetup.py test
}

python_install_all() {
	rst2html.py Changelog.rst > Changelog.html
	rst2html.py README.rst > README.html
	rst2html.py FuturePlans.rst > TODO.html

	local DOCS=()
	local HTML_DOCS=( Changelog.html README.html TODO.html )
	use doc && local HTML_DOCS+=( Doc/apidoc/. Doc/index.html )

	distutils-r1_python_install_all
}
