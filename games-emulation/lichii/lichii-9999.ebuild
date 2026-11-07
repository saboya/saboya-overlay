# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3 xdg

DESCRIPTION="Experimental Nintendo Switch and Switch 2 emulator"
HOMEPAGE="https://github.com/zortos293/Lichii"
EGIT_REPO_URI="https://github.com/zortos293/Lichii.git"
EGIT_BRANCH="nx2"
EGIT_SUBMODULES=()

ZBIC_COMMIT="11b08f2712264bbed731545085cbd9702096ceb7"
ZSTD_COMMIT="33618c89e511637f8a6ef955b3501766d71feb53"

SRC_URI="
	https://github.com/kinnay/zbic/archive/${ZBIC_COMMIT}.tar.gz -> ${PN}-zbic-${ZBIC_COMMIT}.tar.gz
	https://github.com/facebook/zstd/archive/${ZSTD_COMMIT}.tar.gz -> ${PN}-zstd-33618c8.tar.gz
	https://git.eden-emu.dev/eden-emu/tzdb_to_nx/releases/download/230326/230326.tar.gz -> ${PN}-tzdb-230326.tar.gz
	reshade? (
		https://github.com/crosire/reshade/archive/v6.8.0.tar.gz -> ${PN}-reshade-v6.8.0.tar.gz
	)
"

# Includes the licenses of the bundled libraries and timezone data.
LICENSE="GPL-2+ GPL-3+ AGPL-3+ Apache-2.0 BSD BSD-2 MIT public-domain || ( BSD GPL-2 )"
SLOT="0"
IUSE="cli +cubeb +opengl +reshade"

# Upstream unconditionally disables BUILD_TESTING and ENABLE_TESTING.
RESTRICT="test"

# Require minizip-ng too, so QuaZip does not pull in sys-libs/zlib via virtual/minizip.
RDEPEND="
	app-arch/lz4:=
	dev-cpp/cpp-httplib:=[ssl,-mbedtls]
	>=dev-libs/boost-1.84:=[context]
	>=dev-libs/libfmt-8:=
	>=dev-libs/openssl-3:0=
	>=dev-libs/quazip-1.3:=
	>=dev-libs/sirit-1.0.5
	dev-libs/libusb:1
	dev-qt/qtbase:6[concurrent,dbus,gui,network,widgets]
	dev-qt/qtcharts:6
	>=media-libs/libsdl3-3.2.10
	>=media-libs/opus-1.3
	media-libs/vulkan-loader
	media-video/ffmpeg:=[opus]
	>=net-libs/enet-1.3:1.3=
	sys-libs/minizip-ng[compat]
	sys-libs/zlib-ng:=[compat]
	cubeb? ( media-libs/cubeb )
"
DEPEND="
	${RDEPEND}
	>=dev-cpp/nlohmann_json-3.8
	dev-cpp/simpleini
	>=dev-libs/frozen-1.2.0
	>=dev-libs/xbyak-7
	dev-util/spirv-headers
	>=dev-util/vulkan-headers-1.4.317
	dev-util/vulkan-utility-libraries
	>=games-util/gamemode-1.7
	>=media-libs/VulkanMemoryAllocator-3.3.0
"
BDEPEND="
	>=dev-build/cmake-3.31
	dev-util/glslang
	virtual/pkgconfig
"

src_unpack() {
	default
	git-r3_src_unpack
}

src_prepare() {
	cmake_src_prepare

	# CUSTOM_DIR bypasses CPMUtil's patch handling.
	if use reshade; then
		(
			cd "${WORKDIR}/reshade-6.8.0" || die
			eapply "${S}/.patch/reshade/0001-from-chars-fallback.patch"
		)
	fi
}

src_configure() {
	local mycmakeargs=(
		# Fail rather than silently download missing system dependencies.
		-DCPMUTIL_FORCE_SYSTEM=ON
		-DFETCHCONTENT_FULLY_DISCONNECTED=ON
		-DBUILD_TESTING=OFF
		-DDYNARMIC_TESTS=OFF
		-DYUZU_TESTS=OFF
		-DENABLE_WERROR=OFF
		-DENABLE_LTO=OFF
		-DUSE_CCACHE=OFF
		-DUSE_FASTER_LINKER=OFF
		-DYUZU_BUILD_PRESET=custom
		-DENABLE_QT=ON
		-DENABLE_QT_TRANSLATION=OFF
		-DENABLE_CUBEB=$(usex cubeb)
		-DENABLE_OPENGL=$(usex opengl)
		-DENABLE_RESHADE=$(usex reshade)
		-DENABLE_LIBUSB=ON
		-DENABLE_WEB_SERVICE=OFF
		-DENABLE_UPDATE_CHECKER=OFF
		-DENABLE_WIFI_SCAN=OFF
		-DUSE_DISCORD_PRESENCE=OFF
		-DYUZU_CMD=$(usex cli)
		-DYUZU_ROOM=OFF
		-DYUZU_ROOM_STANDALONE=OFF
		-DYUZU_USE_BUNDLED_QT=OFF
		-DYUZU_USE_BUNDLED_FFMPEG=OFF
		-DYUZU_USE_EXTERNAL_FFMPEG=OFF
		-DYUZU_USE_BUNDLED_SDL3=OFF
		-DYUZU_USE_BUNDLED_OPENSSL=OFF
		-DYUZU_USE_BUNDLED_SIRIT=OFF
		-DYUZU_USE_QT_MULTIMEDIA=OFF
		-DYUZU_USE_QT_WEB_ENGINE=OFF
		-DYUZU_INSTALL_UDEV_RULES=OFF
		# The timezone data is embedded; OFF tries to build it from source.
		-DYUZU_DOWNLOAD_TIME_ZONE_DATA=ON
		-DYUZU_TZDB_PATH="${WORKDIR}/nx-tzdb-230326"
		# Upstream requires this exact zstd for reproducible NUP archives.
		-Dzstd_CUSTOM_DIR="${WORKDIR}/zstd-${ZSTD_COMMIT}"
		-DZSTD_BUILD_PROGRAMS=OFF
		-DZSTD_BUILD_TESTS=OFF
		-Dzbic_FORCE_BUNDLED=ON
		-Dzbic_CUSTOM_DIR="${WORKDIR}/zbic-${ZBIC_COMMIT}"
	)
	if use reshade; then
		mycmakeargs+=(
			-Dreshade_FORCE_BUNDLED=ON
			-Dreshade_CUSTOM_DIR="${WORKDIR}/reshade-6.8.0"
		)
	fi
	cmake_src_configure
}

src_install() {
	cmake_src_install

	# The inherited CLI target still uses the eden-cli executable name.
	if use cli; then
		mv "${ED}/usr/bin/eden-cli" "${ED}/usr/bin/${PN}-cli" || die
	fi
}
