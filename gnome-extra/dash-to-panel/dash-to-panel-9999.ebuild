# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit gnome2 git-r3
EGIT_REPO_URI="https://github.com/home-sweet-gnome/dash-to-panel.git"

DESCRIPTION="Dash to Panel extension for the Gnome Shell."
HOMEPAGE="https://github.com/home-sweet-gnome/dash-to-panel"
SRC_URI=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="
	app-eselect/eselect-gnome-shell-extensions
"

RDEPEND="
	gnome-base/gnome-shell
"

src_configure() { :; }

src_compile() {
	emake install
}

src_install() {
	insinto /usr/share/gnome-shell/extensions/
	doins -r "${HOME}/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com"
}

pkg_preinst() {
	gnome2_schemas_savelist
}

pkg_postinst() {
	gnome2_schemas_update
	ebegin "Updating list of installed extensions"
	eselect gnome-shell-extensions update
	eend $?
}