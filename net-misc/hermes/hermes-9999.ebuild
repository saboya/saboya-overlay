# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake fcaps git-r3 optfeature systemd toolchain-funcs udev xdg

DESCRIPTION="Apollo-derived game streaming host for Moonlight and Hestia"
HOMEPAGE="https://github.com/MrOz59/Hermes"
EGIT_REPO_URI="https://github.com/MrOz59/Hermes.git"
EGIT_BRANCH="main"
EGIT_SUBMODULES=(
	third-party/Simple-Web-Server
	third-party/moonlight-common-c
	third-party/nanors
	third-party/tray
)


LICENSE="GPL-3 BSD BSD-2 MIT LGPL-2.1+"
SLOT="0"
IUSE="cuda +kms +systemd +trayicon +vaapi +wayland +X"
REQUIRED_USE="|| ( cuda kms wayland X )"
RESTRICT="test"

RDEPEND="
	>=dev-libs/boost-1.89:=[nls]
	dev-libs/libevdev
	dev-libs/openssl:=
	dev-qt/qtbase:6[concurrent,dbus,gui,network,widgets]
	media-libs/libglvnd
	media-libs/libpulse
	media-libs/mesa
	media-libs/opus
	media-libs/x264:=
	media-video/pipewire:=
	net-libs/miniupnpc:=
	net-dns/avahi
	net-misc/curl
	sys-apps/acl
	sys-apps/util-linux
	sys-libs/libcap
	virtual/libudev:=
	x11-libs/libdrm
	cuda? ( x11-drivers/nvidia-drivers )
	systemd? ( sys-apps/systemd )
	trayicon? ( dev-qt/qtsvg:6 )
	vaapi? ( media-libs/libva:= )
	wayland? ( dev-libs/wayland )
	X? (
		x11-libs/libX11
		x11-libs/libxcb
		x11-libs/libXfixes
		x11-libs/libXrandr
		x11-libs/libXtst
	)
"
DEPEND="
	${RDEPEND}
	>=dev-cpp/nlohmann_json-3.11
	=dev-libs/libdisplaydevice-0_p20250812
	=dev-libs/libvirtualhid-hermes-0_p20261025[X?]
	=net-libs/moonlight-enet-0_p20250704
	=media-libs/hermes-ffmpeg-7.1.5:7=[vaapi=]
	dev-util/vulkan-headers
	=media-libs/nv-codec-headers-13*
	cuda? ( >=dev-util/nvidia-cuda-toolkit-12 )
	wayland? (
		>=gui-libs/wlr-protocols-0_p20260309
		>=dev-libs/wayland-protocols-1.38
		dev-libs/plasma-wayland-protocols
	)
"
BDEPEND="
	>=dev-build/cmake-3.24
	net-libs/nodejs[npm]
	virtual/pkgconfig
	wayland? ( dev-util/wayland-scanner )
"

PATCHES=( "${FILESDIR}/${PN}-9999-system-build.patch" "${FILESDIR}/${PN}-system-libraries.patch" "${FILESDIR}/${PN}-nvenc-13.patch" )

# Vite writes the web assets in the build tree, while npm needs a writable source tree.
CMAKE_IN_SOURCE_BUILD=1

src_unpack() {
	default
	git-r3_src_unpack

	# Like Gentoo's live Sunshine ebuild, fetch npm dependencies in the network-enabled
	# unpack phase, never during configure/compile. Live sources have no lockfile.
	cd "${S}" || die
	npm_config_cache="${T}/npm-cache" npm install --ignore-scripts --no-audit --no-fund || die
}

src_prepare() {
	cmake_src_prepare
	# The upstream target runs npm install again. All dependencies are already present.
	sed -i '/COMMAND .*"${NPM}" install /d' cmake/targets/common.cmake || die
	# Boost.System is header-only and no longer exports a component in Boost 1.89+.
	sed -i '/^        system$/d' cmake/dependencies/Boost_Sunshine.cmake || die
	sed -i \
		-e 's/find_package(Boost 1.53.0 COMPONENTS system REQUIRED)/find_package(Boost 1.89 CONFIG REQUIRED)/' \
		-e 's/Boost::system/Boost::headers/g' \
		third-party/Simple-Web-Server/CMakeLists.txt || die
}

src_configure() {
	local ffmpeg_prefix
	ffmpeg_prefix=$($(tc-getPKG_CONFIG) --variable=sdkdir hermes-ffmpeg-7) || die
	[[ -n ${ffmpeg_prefix} ]] || die "Hermes FFmpeg SDK not found"

	# Avoid mixing system FFmpeg headers with the private CBS headers.
	local mycmakeargs=(
		-Dlibvirtualhid_DIR="${ESYSROOT}/usr/$(get_libdir)/libvirtualhid-hermes/cmake/libvirtualhid"
		-DBUILD_SHARED_LIBS=OFF
		-DBUILD_DOCS=OFF
		-DBUILD_TESTS=OFF
		-DBUILD_TESTING=OFF
		-DBUILD_WERROR=OFF
		-DBOOST_USE_STATIC=OFF
		-DFETCHCONTENT_FULLY_DISCONNECTED=ON
		-DHERMES_FFMPEG_PREFIX="${ffmpeg_prefix}"
		-DHERMES_FFMPEG_SOURCE="${ffmpeg_prefix}/include"
		-DSUNSHINE_ASSETS_DIR="share/${PN}"
		-DSUNSHINE_EXECUTABLE_PATH="${EPREFIX}/usr/bin/hermes"
		-DSUNSHINE_ENABLE_CUDA=$(usex cuda)
		-DCUDA_FAIL_ON_MISSING=$(usex cuda)
		-DSUNSHINE_ENABLE_DRM=$(usex kms)
		-DSUNSHINE_ENABLE_VAAPI=$(usex vaapi)
		-DSUNSHINE_ENABLE_WAYLAND=$(usex wayland)
		-DSUNSHINE_ENABLE_X11=$(usex X)
		-DSUNSHINE_ENABLE_TRAY=$(usex trayicon)
		-DSUNSHINE_SYSTEM_WAYLAND_PROTOCOLS=ON
		-DSUNSHINE_BUILD_CARD_BROKER=OFF
		-DSUNSHINE_BUILD_SESSION_BROKER=OFF
		-DSUNSHINE_BUILD_GAMEMODE_CONSOLE=ON
		-DUDEV_RULES_INSTALL_DIR="$(get_udevdir)/rules.d"
		-DCMAKE_DISABLE_FIND_PACKAGE_Systemd=ON
	)
	local -x BRANCH=main BUILD_VERSION COMMIT
	BUILD_VERSION=$(< VERSION)
	COMMIT=${EGIT_VERSION}
	cmake_src_configure
}

src_compile() {
	local -x npm_config_offline=true npm_config_cache="${T}/npm-cache"
	cmake_src_compile
}

src_install() {
	cmake_src_install
	# Upstream installs a versioned Sunshine executable and an unversioned symlink.
	rm "${ED}/usr/bin/sunshine" || die
	local binaries=( "${ED}"/usr/bin/sunshine-* )
	[[ ${#binaries[@]} == 1 ]] || die "Unexpected upstream executable names"
	mv "${binaries[0]}" "${ED}/usr/bin/hermes" || die

	# Isolated-session brokers are not enabled by this package. Do not install
	# their polkit policy or alter seats / auto-load virtual display modules.
	rm "${ED}/usr/share/polkit-1/rules.d/10-hermes-session-deny.rules" || die
	rm "${ED}$(get_udevdir)/rules.d/74-hermes-session-acl.rules" \
		"${ED}$(get_udevdir)/rules.d/99-hermes-session-input.rules" || die
	if use systemd; then
		systemd_newuserunit "${BUILD_DIR}/sunshine.service" hermes.service
	fi
	insinto /usr/lib/modules-load.d
	newins "${FILESDIR}/hermes-modules.conf" hermes.conf
}

pkg_postinst() {
	xdg_pkg_postinst
	udev_reload
	use kms && fcaps cap_sys_admin+p usr/bin/hermes
	elog "Run Hermes as your desktop user, not root: hermes"
	use systemd && elog "Or start the user service: systemctl --user enable --now hermes.service"
	elog "Configure and pair Moonlight at https://localhost:47990"
	elog "Load uinput and uhid (or reboot) to enable virtual controller input."
	elog "For existing-monitor streaming, set virtual_display_backend = none."
	elog "Hermes-KMS/EVDI drivers are separate; privileged isolated-session brokers"
	elog "and the experimental PyroWave codec are not included in this package."
	elog "Sunshine/Apollo may coexist, but must not listen on the same ports."
	optfeature "Wayland clipboard synchronization" gui-apps/wl-clipboard
	optfeature "X11 clipboard synchronization" x11-misc/xclip
}

pkg_postrm() {
	xdg_pkg_postrm
	udev_reload
}
