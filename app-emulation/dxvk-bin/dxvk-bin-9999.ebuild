# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit git-r3

DESCRIPTION="Vulkan-based D3D11 implementation for Linux / Wine"
HOMEPAGE="https://github.com/doitsujin/dxvk"
RESTRICT="mirror"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS=""

RDEPEND=""

S="${WORKDIR}"

BUILDS_URI="https://haagch.frickel.club/files/dxvk"
DXVK_FILES=( d3d11.dll dxgi.dll setup_dxvk.sh )
DXVK_ARCHES=( 32 64 )

src_unpack() {
	for arch in "${DXVK_ARCHES[@]}"
	do
		for file in "${DXVK_FILES[@]}"
		do
			wget -c "${BUILDS_URI}/latest/${arch}/bin/${file}" -P "${S}/x${arch}"
		done
	done
}

src_install() {
	local destdir="/opt/${PN}"

	insinto $destdir
	doins -r x32 x64
}
