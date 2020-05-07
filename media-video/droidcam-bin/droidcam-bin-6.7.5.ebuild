# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

inherit eutils linux-mod user

DESCRIPTION="Use your Android phone as a wireless webcam"
HOMEPAGE="http://www.dev47apps.com/"
SRC_URI="
	amd64? ( https://www.dev47apps.com/files/linux/droidcam_latest.zip -> droidcam-64bit-${PV}.zip )
	https://files.dev47apps.net/img/app_icon.png -> droidcam-icon-${PV}.png"

LICENSE="as-is"

SLOT="0"
KEYWORDS="~amd64"
IUSE=""
DEPEND="net-wireless/bluez"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

BUILD_TARGETS="all"
BUILD_TARGET_ARCH="${ARCH}"
MODULE_NAMES="v4l2loopback-dc(kernel/drivers/media/v4l2-core:${S}/v4l2loopback)"
RESTRICT="mirror"

src_install() {
	dobin droidcam droidcam-cli
	# doicon droidcam.png
	newicon ${DISTDIR}/droidcam-icon-${PV}.png droidcam.png
	linux-mod_src_install
	dodoc README.md
	# Does not exist
	#domenu "${FILESDIR}"/droidcam.desktop
}
