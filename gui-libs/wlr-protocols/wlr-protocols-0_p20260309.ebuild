# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

COMMIT="bf4fc79abc359eea5a0edec0ac6d4a2b2955f82a"
DESCRIPTION="Wayland protocol XML definitions for wlroots and other compositors"
HOMEPAGE="https://gitlab.freedesktop.org/wlroots/wlr-protocols"
SRC_URI="https://gitlab.freedesktop.org/wlroots/wlr-protocols/-/archive/${COMMIT}/${PN}-${COMMIT}.tar.bz2"
S="${WORKDIR}/${PN}-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

src_compile() { :; }

src_install() {
	insinto /usr/share/wlr-protocols
	doins -r unstable
	dodoc README.md

	local pc="${T}/${PN}.pc"
	cat > "${pc}" <<-EOF || die
		prefix=${EPREFIX}/usr
		datadir=\${prefix}/share
		pkgdatadir=\${datadir}/wlr-protocols
		Name: wlr-protocols
		Description: Wayland protocols for wlroots and other compositors
		Version: ${PV}
	EOF
	insinto /usr/share/pkgconfig
	doins "${pc}"
}
