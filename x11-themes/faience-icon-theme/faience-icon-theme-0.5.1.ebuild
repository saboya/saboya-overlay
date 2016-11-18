# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit gnome2-utils

MY_P=${PN}_${PV}

DESCRIPTION="A scalable icon theme called Faience"
HOMEPAGE="http://tiheum.deviantart.com/art/Faience-icon-theme-255099649"

# Use Ubuntu repo which has a proper faience-icon-theme tarball
#SRC_URI="http://${PN}.googlecode.com/files/${PN}_${PV}.tar.gz"
SRC_URI="http://ppa.launchpad.net/tiheum/equinox/ubuntu/pool/main/${PN:0:1}/${PN}/${MY_P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="minimal"

DEPEND=""
RDEPEND="!minimal? ( x11-themes/gnome-icon-theme )
	x11-themes/hicolor-icon-theme"

S=${WORKDIR}/${PN}-${PV%.*}
RESTRICT="binchecks mirror strip"

src_prepare() {
#	local res x
#	for x in Faience Faience-Azur Faience-Ocre Faience-Claire; do
#		for res in 22 24 32 48 64 96; do
#			cp "${x}"/places/${res}/start-here-gentoo.png \
#				"${x}"/places/${res}/start-here.png || die
#		done
#		cp "${x}"/places/scalable/start-here-gentoo-symbolic.svg \
#			"${x}"/places/scalable/start-here.svg || die
#	done
		cp Faience/places/scalable/start-here-gentoo-symbolic.svg \
			Faience/places/scalable/start-here.svg || die
}

src_install() {
	insinto /usr/share/icons
	doins -r Faience{,-Azur,-Ocre,-Claire}
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}