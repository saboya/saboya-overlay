# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

COMMIT="115a10baa1d7f291ff5b870765610fd3b4a6e43c"
DESCRIPTION="Moonlight's IPv6-enabled ENet fork (incompatible with standard ENet)"
HOMEPAGE="https://github.com/cgutman/enet"
SRC_URI="https://github.com/cgutman/enet/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/enet-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

src_prepare() {
	cat "${FILESDIR}/install-sdk.cmake" >> CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=( -DENET_NO_INSTALL=ON )
	cmake_src_configure
}
