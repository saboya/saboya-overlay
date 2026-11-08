# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

COMMIT="14ee6c4717d32b678c2983bfa6c54019b944d421"
DESCRIPTION="Hermes fork of the virtual HID controller library"
HOMEPAGE="https://github.com/MrOz59/libvirtualhid"
SRC_URI="https://github.com/MrOz59/libvirtualhid/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/libvirtualhid-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="X"
RESTRICT="test"

DEPEND="
	dev-libs/libevdev
	X? (
		x11-libs/libX11
		x11-libs/libXtst
	)
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_configure() {
	local mycmakeargs=(
		-DBUILD_DOCS=OFF
		-DBUILD_TESTS=OFF
		-DBUILD_EXAMPLES=OFF
		-DLIBVIRTUALHID_BUILD_TOOLS=OFF
		-DLIBVIRTUALHID_ENABLE_PACKAGING=OFF
		-DLIBVIRTUALHID_WARNINGS_AS_ERRORS=OFF
		-DLIBVIRTUALHID_ENABLE_XTEST=$(usex X)
		-DLIBVIRTUALHID_INSTALL=ON
		# Keep this fork's SDK separate from LizardByte's incompatible upstream.
		-DCMAKE_INSTALL_INCLUDEDIR=include/libvirtualhid-hermes
		-DCMAKE_INSTALL_LIBDIR="$(get_libdir)/libvirtualhid-hermes"
	)
	cmake_src_configure
}
