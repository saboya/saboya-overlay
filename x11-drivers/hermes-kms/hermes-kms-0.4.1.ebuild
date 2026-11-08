# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1 toolchain-funcs udev

DESCRIPTION="Virtual DRM/KMS display kernel module for Hermes streaming"
HOMEPAGE="https://github.com/MrOz59/Hermes-KMS"
SRC_URI="https://github.com/MrOz59/Hermes-KMS/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/Hermes-KMS-${PV}"

LICENSE="GPL-2 MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+tools test"
RESTRICT="!test? ( test )"

RDEPEND="sys-apps/acl"
DEPEND="
	tools? ( x11-libs/libdrm )
	test? ( x11-libs/libdrm )
"
BDEPEND="test? ( virtual/pkgconfig )"

MODULES_KERNEL_MIN=6.8

pkg_setup() {
	local CONFIG_CHECK="DRM DRM_KMS_HELPER DRM_GEM_SHMEM_HELPER DMA_SHARED_BUFFER SHMEM MMU"
	linux-mod-r1_pkg_setup
}

src_compile() {
	local modlist=( "hermes_kms=extra/hermes-kms::kernel/hermes-kms:modules" )
	local modargs=( KDIR="${KV_OUT_DIR}" KERNELRELEASE="${KV_FULL}" )
	linux-mod-r1_src_compile

	if use tools; then
		# Build only the administration CLI, not upstream's GPU diagnostics.
		"$(tc-getCC)" ${CPPFLAGS} ${CFLAGS} -Iinclude/uapi \
			tools/hermes-kmsctl/hermes_kmsctl.c ${LDFLAGS} \
			-o hermes-kmsctl || die
	fi
}

src_test() {
	# These tests need no driver, DRM master, GPU access or module loading.
	emake CC="$(tc-getCC)" CFLAGS="${CFLAGS}" \
		check-uapi check-session check-edid
}

src_install() {
	linux-mod-r1_src_install
	udev_dorules udev/72-hermes-kms-render-access.rules \
		udev/92-hermes-kms-access.rules udev/95-hermes-kms-host-access.rules
	exeinto /usr/lib/hermes-kms
	doexe scripts/hermes-kms-render-acl
	insinto /usr/lib/modprobe.d
	doins packaging/modprobe.d/hermes-kms.conf
	insinto /usr/lib/modules-load.d
	doins packaging/modules-load.d/hermes-kms.conf
	if use tools; then
		dobin hermes-kmsctl
	fi
	dodoc CHANGELOG.md docs/releases/v${PV}.md
}

pkg_postinst() {
	linux-mod-r1_pkg_postinst
	udev_reload
	elog "Hermes-KMS is experimental. No module was loaded or unloaded by this package."
	elog "Stop streams before loading it: modprobe hermes_kms initial_enabled=0 outputs=1"
	elog "If replacing a loaded version, reboot; do not force-unload a DRM device in use."
	elog "Packaged defaults keep the connector disconnected until Hermes requests it."
	elog "Check /etc/modprobe.d for older overrides of initial_enabled."
	elog "Use Hermes >=0.7.0 for the driver's read-only render-node permissions."
	elog "On GNOME Wayland, run Hermes in your logged-in desktop session and set:"
	elog "  virtual_display_backend = hermes_kms"
	elog "Request a virtual display in the streaming application/client settings."
	elog "Keep physical monitors enabled for the first test; try 1280x800 at 60 Hz, SDR."
	elog "NVIDIA uses NVENC with a CPU-copy capture path, not zero-copy."
	elog "Private session brokers and their seat/polkit changes are not installed."
}

pkg_postrm() {
	udev_reload
}
