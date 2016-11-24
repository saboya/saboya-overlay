# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit git-r3
DESCRIPTION="Super Flat remix is a pretty simple icon theme for Linux."
HOMEPAGE="https://github.com/daniruiz/Flat-Remix"

if [[ ${PV} == "9999" ]] ; then
	SRC_URI=""
	EGIT_REPO_URI="https://github.com/daniruiz/${PN}.git"
	KEYWORDS=""
else
	SRC_URI=""
	KEYWORDS="~amd64 ~arm ~x86"
fi

LICENSE="CC-BY-SA-4.0"
SLOT="0"

DEPEND=""
RDEPEND="${DEPEND}"

src_install() {
	insinto /usr/share/icons
	doins -r Flat\ Remix
	dodoc README.md
}
