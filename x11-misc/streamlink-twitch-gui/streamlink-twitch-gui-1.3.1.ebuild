# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils

DESCRIPTION="A multi platform Twitch.tv browser for Streamlink"

HOMEPAGE="https://github.com/streamlink/streamlink-twitch-gui"

SRC_URI="https://github.com/streamlink/streamlink-twitch-gui/releases/download/v${PV}/${PN}-v${PV}-linux64.tar.gz"
RESTRICT="mirror"
KEYWORDS="~amd64"

SLOT="0"
LICENSE="hammer-and-chisel"
RDEPEND=""
DEPEND="${RDEPEND}
	>=net-misc/streamlink-0.2.0
	<=net-misc/streamlink-0.7.0
	dev-libs/nss
	gnome-base/gconf
	media-libs/alsa-lib
	media-libs/libpng
	net-libs/gnutls
	sys-libs/zlib
	x11-libs/gtk+
	x11-libs/libnotify
	x11-libs/libxcb
	x11-libs/libXtst
	"

S=${WORKDIR}/streamlink-twitch-gui

src_install() {
	local destdir="/opt/${PN}"

	insinto $destdir
	doins -r icons locales lib
	doins \
		add-menuitem.sh \
		icudtl.dat \
		natives_blob.bin \
		nw_100_percent.pak \
		nw_200_percent.pak \
		remove-menuitem.sh \
		resources.pak \
		snapshot_blob.bin \
		start.sh \
		streamlink-twitch-gui

	exeinto $destdir

	doexe \
		add-menuitem.sh \
		remove-menuitem.sh \
		start.sh \
		streamlink-twitch-gui
}
