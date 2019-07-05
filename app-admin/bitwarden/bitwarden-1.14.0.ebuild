# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit rpm

DESCRIPTION="A secure and free password manager for all of your devices."
HOMEPAGE="https://bitwarden.com/"

BPN="${PN^}"

SRC_URI="https://github.com/${PN}/desktop/releases/download/v${PV}/${BPN}-${PV}-x86_64.rpm"

SLOT="0"
KEYWORDS="~amd64"
DEPEND="app-shells/bash
	x11-libs/libXScrnSaver
	dev-libs/libappindicator
	x11-libs/libnotify"
RDEPEND="${DEPEND}"

src_unpack() {
	rpm_src_unpack ${A}
	mkdir -p "${S}" # Without this src_prepare fails
}

src_install() {
	cp -pPR "${WORKDIR}"/{opt,usr} "${D}"/ || die "Installation failed"

	insinto / && doins -r / || die

}
