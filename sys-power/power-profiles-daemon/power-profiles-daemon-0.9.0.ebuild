# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit gnome2-utils meson systemd xdg

DESCRIPTION="Makes power profiles handling available over D-Bus"
HOMEPAGE="https://gitlab.freedesktop.org/hadess/power-profiles-daemon"
SRC_URI="https://gitlab.freedesktop.org/hadess/${PN}/-/archive/${PV}/${PN}-${PV}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"

IUSE="doc"

RDEPEND="
	>=dev-libs/libgudev-234:0=
	>=dev-libs/glib-2.61.3:2
	>=sys-apps/systemd-222:0=
	>=sys-power/upower-0.99.11:0=
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-util/gdbus-codegen
	>=dev-util/meson-0.54.0
"

src_configure() {
	local emesonargs=(
		$(meson_use doc gtk_doc)
		-Dsystemdsystemunitdir=$(systemd_get_systemunitdir)
	)
	meson_src_configure
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}