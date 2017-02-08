# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python{2_7,3_4,3_5} )

inherit distutils-r1

DESCRIPTION="CLI for extracting streams from websites to a video player of your choice"
HOMEPAGE="https://streamlink.github.io/"
SRC_URI="https://github.com/${PN}/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

KEYWORDS="~amd64 ~arm ~x86"
LICENSE="BSD-2"
SLOT="0"
IUSE="doc test +cryptodome"

RDEPEND="cryptodome? ( dev-python/pycryptodome[${PYTHON_USEDEP},namespaced] ) !cryptodome? ( dev-python/pycryptodome[${PYTHON_USEDEP},-namespaced] )
	dev-python/requests[${PYTHON_USEDEP}]
	virtual/python-futures[${PYTHON_USEDEP}]
	virtual/python-singledispatch[${PYTHON_USEDEP}]
	dev-python/iso3166[${PYTHON_USEDEP}]
	dev-python/iso639[${PYTHON_USEDEP}]
	media-video/rtmpdump"
DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/backports-shutil_get_terminal_size[$(python_gen_usedep 'python2*')]
	dev-python/backports-shutil_which[$(python_gen_usedep 'python2*')]
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )
	test? ( ${RDEPEND} )"

python_prepare_all() {
	if use cryptodome; then
		local PATCHES=(
			${FILESDIR}/${PV}-cryptodomex.patch
		)
	fi

	distutils-r1_python_prepare_all
}

python_compile_all() {
	use doc && emake -C docs html
}

python_test() {
	esetup.py test
}

python_install_all() {
	use doc && local HTML_DOCS=( docs/_build/html/. )
	distutils-r1_python_install_all
}
