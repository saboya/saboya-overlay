# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	block-buffer@0.10.4
	cc@1.11.0
	cfg-if@1.0.5
	cpufeatures@0.2.17
	crypto-common@0.1.7
	digest@0.10.7
	find-msvc-tools@0.1.15
	generic-array@0.14.7
	jobserver@0.1.32
	libc@0.2.191
	pkg-config@0.3.34
	same-file@1.0.6
	sha2@0.10.9
	shlex@2.0.1
	typenum@1.20.1
	version_check@0.9.5
	winapi-util@0.1.11
	windows-link@0.2.1
	windows-sys@0.61.2
	zstd@0.14.3
	zstd-safe@8.2.0
	zstd-sys@2.1.2+zstd.1.5.7
"

inherit cargo

DESCRIPTION="C API and C++ reader for NX game archives"
HOMEPAGE="https://github.com/fab918/nxformat"
SRC_URI="
	https://github.com/fab918/nxformat/archive/refs/tags/V${PV}.tar.gz -> ${P}.tar.gz
	${CARGO_CRATE_URIS}
"
S="${WORKDIR}/${P}/ffi"

LICENSE="Apache-2.0 BSD MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=">=app-arch/zstd-1.5.7:="
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_configure() {
	# Also leaves the static archive without bundled Zstandard objects, as
	# required by Lichii, which links its own pinned Zstandard implementation.
	export ZSTD_SYS_USE_PKG_CONFIG=1
	cargo_src_configure
}

src_install() {
	dolib.so "$(cargo_target_dir)/libnxformat.so"
	dolib.a "$(cargo_target_dir)/libnxformat.a"
	doheader include/nxformat.h ../dist/*.hpp
	insinto /usr/$(get_libdir)/cmake/nxformat
	doins "${FILESDIR}/nxformatConfig.cmake"
	newins "${FILESDIR}/nxformatConfigVersion.cmake" nxformatConfigVersion.cmake
	dodoc ../README.md
}
