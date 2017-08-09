# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

PYTHON_COMPAT=( python2_7 python3_4 )
PYTHON_REQ_USE='threads(+)' # required by waf

inherit git-r3 python-any-r1 gnome2-utils waf-utils

DESCRIPTION="Control UPnP of a router"
HOMEPAGE="https://launchpad.net/upnp-router-control"
EGIT_REPO_URI="https://git.launchpad.net/upnp-router-control"

LICENSE="|| ( GPL-2 GPL-3 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+curl"

RDEPEND=">=net-libs/gupnp-0.14.1
	curl? ( net-misc/curl )
	x11-libs/gtk+:2"

DEPEND="${RDEPEND}
	dev-util/intltool"

NO_WAF_LIBDIR="true"

src_configure() {
	libdir='' waf-utils_src_configure
}

src_compile() {
	waf-utils_src_compile
}

src_install() {
	waf-utils_src_install
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
