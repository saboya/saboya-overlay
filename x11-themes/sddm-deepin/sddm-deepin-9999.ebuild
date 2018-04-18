# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

inherit git-r3

DESCRIPTION="Deepin style SDDM theme."
HOMEPAGE="https://github.com/Match-Yang/sddm-deepin"

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/Match-Yang/${PN}.git"
	KEYWORDS=""
else
	SRC_URI=""
	KEYWORDS="~amd64 ~arm ~x86"
fi

LICENSE="MIT"
SLOT="0"

DEPEND=""
RDEPEND="
	dev-qt/qtgraphicaleffects:5
	x11-misc/sddm
"

src_install() {
	insinto /usr/share/sddm/themes
	doins -r deepin/
}
