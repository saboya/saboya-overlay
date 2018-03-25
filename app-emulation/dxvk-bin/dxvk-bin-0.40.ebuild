# Distributed under the terms of the GNU General Public License v2

EAPI="6"

DESCRIPTION="Vulkan-based D3D11 implementation for Linux / Wine"
HOMEPAGE="https://github.com/doitsujin/dxvk"
SRC_URI="https://github.com/doitsujin/dxvk/releases/download/v${PV}/dxvk-v${PV}.tar.gz"
RESTRICT="mirror"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND=""

S="${WORKDIR}/dxvk-${PV}"

src_install() {
	local destdir="/opt/${PN}"

	insinto $destdir
	doins -r x32 x64
}
