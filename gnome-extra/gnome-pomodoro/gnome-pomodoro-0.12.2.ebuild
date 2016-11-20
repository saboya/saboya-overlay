# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

VALA_MIN_API_VERSION="0.28"
VALA_USE_DEPEND="vapigen"

inherit autotools vala gnome2

DESCRIPTION="Time management utility for GNOME based on the pomodoro technique"
HOMEPAGE="http://gnomepomodoro.org"
SRC_URI="https://github.com/codito/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

COMMON_DEPEND="
	>=dev-libs/glib-2.38:2
	>=dev-libs/gobject-introspection-1.36
	>=dev-libs/libpeas-1.5.0
	>=gnome-base/gnome-desktop-3.16.0:3
	>=gnome-base/gsettings-desktop-schemas-3.14.0
	>=media-libs/gstreamer-1.0.10
	>=media-libs/libcanberra-0.30
	>=x11-libs/gtk+-3.16.0:3=[introspection]
"

DEPEND="${COMMON_DEPEND}
	app-text/docbook-sgml-utils
	app-text/docbook-sgml-dtd:4.1
	>=dev-util/intltool-0.40.1
	>=dev-util/pkgconfig-0.22
	$(vala_depend)
"

RDEPEND="${COMMON_DEPEND}"

src_prepare() {
	eautoreconf
	vala_src_prepare
}
