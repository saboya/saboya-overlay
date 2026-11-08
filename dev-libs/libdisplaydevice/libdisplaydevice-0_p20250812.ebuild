# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

COMMIT="f31e46d8736fa6932d34c1417111e60ca507b29f"
DESCRIPTION="Display-device configuration library used by Sunshine and Hermes"
HOMEPAGE="https://github.com/LizardByte/libdisplaydevice"
SRC_URI="https://github.com/LizardByte/libdisplaydevice/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${COMMIT}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

DEPEND=">=dev-cpp/nlohmann_json-3.11"
RDEPEND="${DEPEND}"

src_prepare() {
	# The upstream snapshot only supports add_subdirectory, not installed SDKs.
	cat "${FILESDIR}/install-sdk.cmake" >> CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=OFF
		-DBUILD_DOCS=OFF
		-DBUILD_TESTS=OFF
		-DFETCHCONTENT_FULLY_DISCONNECTED=ON
	)
	cmake_src_configure
}
