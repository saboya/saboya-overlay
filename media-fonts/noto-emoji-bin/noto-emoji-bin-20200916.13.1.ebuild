# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

GITHUB_USER="googlefonts"
GITHUB_PROJ="${PN%%-bin}"
KEYWORDS="amd64 arm arm64 mips ppc ppc64 x86"

inherit font github-pkg

DESCRIPTION="Google Noto Color Emoji, upstream-prebuilt version"
HOMEPAGE="https://www.google.com/get/noto/ https://github.com/googlefonts/noto-emoji"

if [[ ${PV} != 9999 ]]; then
	# 20191119.12   -> 2019-11-19-unicode12
	# 20200408.12.1 -> 2019-11-19-unicode12_1
	UNI_VER="${PV#*.}"
	MY_PV="${PV:0:4}-${PV:4:2}-${PV:6:2}-unicode${UNI_VER/./_}"
	SRC_URI="${GITHUB_HOMEPAGE}/archive/v${MY_PV}.tar.gz -> ${GITHUB_PROJ}-${MY_PV}.tar.gz"
	S="${WORKDIR}/${GITHUB_PROJ}-${MY_PV}/fonts"
else
	BDEPEND="app-arch/unzip"
	S="${WORKDIR}/${P}/fonts"
fi

LICENSE="OFL-1.1"
SLOT="0"

FONT_SUFFIX="ttf"