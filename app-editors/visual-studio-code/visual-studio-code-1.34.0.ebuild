# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils pax-utils xdg-utils

DESCRIPTION="Multiplatform Visual Studio Code from Microsoft"
HOMEPAGE="https://code.visualstudio.com"
BASE_URI="https://vscode-update.azurewebsites.net/${PV}"
SRC_URI="
	x86? ( ${BASE_URI}/linux-ia32/stable ->  ${P}-x86.tar.gz )
	amd64? ( ${BASE_URI}/linux-x64/stable -> ${P}-amd64.tar.gz )
	"
RESTRICT="mirror strip bindist"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="libsecret"

DEPEND="
	>=media-libs/libpng-1.2.46
	>=x11-libs/gtk+-2.24.8-r1:2
	x11-libs/cairo
	gnome-base/gconf
	x11-libs/libXtst
"

RDEPEND="
	${DEPEND}
	x11-libs/libnotify
	x11-libs/libXScrnSaver
	dev-libs/nss
	libsecret? ( app-crypt/libsecret[crypt] )
"

QA_PRESTRIPPED="opt/${PN}/code"
QA_PREBUILT="opt/${PN}/code"

pkg_setup(){
	use amd64 && S="${WORKDIR}/VSCode-linux-x64" || S="${WORKDIR}/VSCode-linux-ia32"
}

src_install(){
	local targetdir="/opt/${PN}"

	pax-mark m code
	insinto $targetdir
	doins -r *
	dosym "/opt/${PN}/code" "/usr/bin/visual-studio-code"
	make_wrapper "${PN}" "/opt/${PN}/code"
	make_desktop_entry "${PN} %F" "Visual Studio Code" "${PN}" "Development;IDE" "StartupWMClass=code"
	doicon ${FILESDIR}/${PN}.png
	fperms +x "${targetdir}/code"
	fperms +x "${targetdir}/bin/code"
	fperms +x "${targetdir}/libnode.so"
	fperms +x "${targetdir}/resources/app/node_modules.asar.unpacked/vscode-ripgrep/bin/rg"
	fperms +x "${targetdir}/resources/app/extensions/git/dist/askpass.sh"
	insinto "/usr/share/licenses/${PN}"
	newins "resources/app/LICENSE.rtf" "LICENSE.rtf"
}

pkg_postinst(){
	xdg_desktop_database_update
	elog "You may install some additional utils, so check them in:"
	elog "https://code.visualstudio.com/Docs/setup#_additional-tools"
}

pkg_postrm(){
	xdg_desktop_database_update
}