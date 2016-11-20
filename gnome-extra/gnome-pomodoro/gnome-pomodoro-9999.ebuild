# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

VALA_MIN_API_VERSION="0.26"
VALA_USE_DEPEND="vapigen"

inherit autotools vala gnome2 git-r3
EGIT_REPO_URI="https://github.com/codito/gnome-pomodoro"

DESCRIPTION="Time management utility for GNOME based on the pomodoro technique"
HOMEPAGE="http://gnomepomodoro.org"
SRC_URI=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

COMMON_DEPEND="
	dev-libs/dbus-glib
	>=dev-libs/glib-2.38:2
	>=dev-libs/gobject-introspection-1.36
	>=dev-libs/libpeas-1.5.0
	>=gnome-base/gnome-desktop-3.14.0:3
	>=gnome-base/gsettings-desktop-schemas-3.14.0
	>=media-libs/gstreamer-1.0.10
	>=media-libs/libcanberra-0.30
	>=net-libs/telepathy-glib-0.17.5
	>=x11-libs/gtk+-3.14.0:3=[introspection]
"

DEPEND="${COMMON_DEPEND}
	app-text/docbook-sgml-utils
	app-text/docbook-sgml-dtd:4.1
	>=sys-devel/gettext-0.19.6
	>=dev-util/pkgconfig-0.22
	$(vala_depend)
"

RDEPEND="${COMMON_DEPEND}"

src_prepare() {
	eautoreconf
	gnome2_src_prepare
	vala_src_prepare
}