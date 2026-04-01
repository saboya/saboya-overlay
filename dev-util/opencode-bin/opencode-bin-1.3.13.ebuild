# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Open source AI coding agent (prebuilt binary)"
HOMEPAGE="https://opencode.ai/ https://github.com/anomalyco/opencode"
SRC_URI="
	amd64? ( https://github.com/anomalyco/opencode/releases/download/v${PV}/opencode-linux-x64.tar.gz -> ${P}-amd64.tar.gz )
	arm64? ( https://github.com/anomalyco/opencode/releases/download/v${PV}/opencode-linux-arm64.tar.gz -> ${P}-arm64.tar.gz )
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

RDEPEND="sys-libs/glibc"

QA_PREBUILT="usr/bin/opencode"

src_install() {
	dobin opencode
}
