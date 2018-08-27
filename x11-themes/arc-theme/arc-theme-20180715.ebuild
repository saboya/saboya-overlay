# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit autotools

DESCRIPTION="A flat theme with transparent elements"
HOMEPAGE="https://github.com/NicoHood/arc-theme"

SRC_URI=""

if [[ ${PV} == "9999" ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/NicoHood/Arc-theme.git"
else
	SRC_URI="https://github.com/NicoHood/arc-theme/archive/${PV}.tar.gz -> ${P}.tar.gz"
fi

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="
	cinnamon
	+dark
	darker
	gnome
	+gtk2
	+gtk3
	light
	mate
	plank
	transparency
	unity
	xfce
"

REQUIRED_USE="
	|| ( dark darker light )
"

# Supports various GTK+3 versions and uses pkg-config to determine which set of
# files to install. Updates will break it but only this fix will help.
# https://github.com/horst3180/arc-theme/pull/436
DEPEND="
	gtk3? (
		>=x11-libs/gtk+-3.14:3
	)
"

# gnome-themes-standard is only needed by GTK+2 for the Adwaita
# engine. This engine is built into GTK+3.
RDEPEND="
	gtk2? (
		x11-themes/gnome-themes-extra
	)
	x11-themes/gtk-engines-murrine
"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable cinnamon) \
		$(use_enable dark) \
		$(use_enable darker) \
		$(use_enable gnome gnome-shell) \
		$(use_enable gtk2) \
		$(use_enable gtk3) \
		$(use_enable light) \
		$(use_enable mate metacity) \
		$(use_enable transparency) \
		$(use_enable unity) \
		$(use_enable xfce xfwm)
}

src_install() {
	emake DESTDIR="${D}" install
}
