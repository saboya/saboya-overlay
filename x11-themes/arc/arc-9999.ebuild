# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit git-r3 autotools

DESCRIPTION="Arc is a flat theme with transparent elements for GTK 3, GTK 2 and Gnome-Shell."
HOMEPAGE="https://github.com/horst3180/Arc-theme"
SRC_URI=""
EGIT_REPO_URI="https://github.com/horst3180/Arc-theme.git"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="+gtk2 +gtk3 +light +darker +dark +transparency -cinnamon -metacity -unity -xfwm -gnome-shell -xfce-notify"

DEPEND="x11-themes/gnome-themes-standard
x11-themes/gtk-engines-murrine"
RDEPEND="${DEPEND}"

src_prepare() {
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable gtk2) \
		$(use_enable gtk3) \
		$(use_enable light) \
		$(use_enable darker) \
		$(use_enable dark) \
		$(use_enable cinnamon) \
		$(use_enable transparency) \
		$(use_enable metacity) \
		$(use_enable unity) \
		$(use_enable xfwm) \
		$(use_enable xfce-notify) \
		$(use_enable gnome-shell)
}
