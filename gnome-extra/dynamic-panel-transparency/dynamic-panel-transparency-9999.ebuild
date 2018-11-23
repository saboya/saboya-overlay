# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit gnome2 git-r3
EGIT_REPO_URI="https://github.com/rockon999/dynamic-panel-transparency.git"

DESCRIPTION="Adds Transparency To The Gnome Shell Panel."
HOMEPAGE="https://github.com/rockon999/dynamic-panel-transparency"
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

src_install() {
	insinto /usr/share/gnome-shell/extensions/
	doins -r dynamic-panel-transparency@rockon999.github.io
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