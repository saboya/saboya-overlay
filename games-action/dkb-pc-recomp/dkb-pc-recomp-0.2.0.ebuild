# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
inherit python-single-r1

MY_P="DKB-Setup-${PV}+33f8bbc-linux"

DESCRIPTION="Source-based installer for the Donkey Kong Bananza PC recompilation"
HOMEPAGE="https://github.com/Lucas-blip-png/dkb-pc-recomp"
SRC_URI="https://github.com/Lucas-blip-png/dkb-pc-recomp/releases/download/v${PV}/${MY_P}-x86_64.tar.gz"
S="${WORKDIR}/${MY_P}"

# Includes the bundled runtime, translator sources, and Roboto font.
LICENSE="GPL-3+ MIT ZLIB Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# Compilation happens as the user, after installation, using their own game dump.
# These are deliberately runtime dependencies rather than BDEPEND.
RDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/cffi[${PYTHON_USEDEP}]
		dev-python/cryptography[${PYTHON_USEDEP}]
		dev-python/lz4[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/pycparser[${PYTHON_USEDEP}]
	')
	app-arch/zstd
	dev-build/ninja
	dev-util/spirv-tools
	dev-util/vulkan-headers
	dev-vcs/git
	llvm-core/clang
	llvm-core/lld
	media-libs/libsdl3
	media-libs/libvpx
	media-libs/opus
	media-libs/vulkan-loader
	>=media-libs/VulkanMemoryAllocator-3.4.0
	sys-devel/gcc
	virtual/dotnet-sdk:10.0
"

src_prepare() {
	default

	# Use the system C++ runtime rather than requiring a static GCC library.
	sed -i "s/'-l:libstdc++.a'/'-lstdc++'/g" tools/build_game.py || die
	# The POSIX source release calls this dkb.ini.example, unlike the checkout.
	sed -i "s@ini_example=root / 'totk.ini.example', temp=@ini_example=root / 'dkb.ini.example', temp=@" \
		installer/layout.py || die
}

src_compile() { :; }

src_test() {
	"${PYTHON}" -B -m installer --help > /dev/null || die
	PYTHONPATH="${S}/tools" "${PYTHON}" -B -c \
		'import build_xlate; assert len(build_xlate.identity()) == 64' || die
}

src_install() {
	insinto /usr/share/${PN}
	doins -r installer recomp runtime tools licenses
	doins VERSION dkb.ini.example LICENSE LICENSE-MIT THIRD_PARTY_NOTICES.md

	local launcher="${T}/${PN}-setup"
	sed \
		-e "s|@PYTHON@|${PYTHON}|g" \
		-e "s|@ROOT@|${EPREFIX}/usr/share/${PN}|g" \
		"${FILESDIR}/${PN}-setup" > "${launcher}" || die
	dobin "${launcher}"

	dodoc README-SETUP.txt THIRD_PARTY_NOTICES.md
}

pkg_postinst() {
	elog "Run dkb-pc-recomp-setup --help for installer options. For example:"
	elog "  dkb-pc-recomp-setup --nup /path/to/game.nup --dest /path/to/dkb"
	elog "You must supply your own game dump (1.0.0 or 3.2.0). No game data is included."
	elog "The installer builds the game and translator as your user, outside Portage."
	elog "The translator's dotnet publish step needs network access for NuGet packages."
	elog "Linux >= 6.7, an AVX2 CPU and a Vulkan 1.3 GPU/driver are required."
	elog "Allow substantial free disk space and at least 16 GiB RAM plus swap."
	elog "Linux support is experimental; crashes and rendering problems are expected."
}
