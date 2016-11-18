# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils fdo-mime

DESCRIPTION="RescueTime automatically builds a record of the activities and websites you are spending time with"
HOMEPAGE="https://www.rescuetime.com"
SRC_URI="https://www.rescuetime.com/installers/rescuetime-x86_64-2.8.9.1185.deb"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

RESTRICT="fetch"

src_unpack() {
	unpack "$A"
	cd "$WORKDIR"
	mkdir -p "$P"
	[ -f 'data.tar.gz' ] || die "Internal archive does not exist."
	tar xzf 'data.tar.gz' -C "$WORKDIR/$P"
	rm -f 'data.tar.gz'
	cd -
}

src_install() {
	cp -a "$S/usr" "$D"
	make_desktop_entry "/usr/bin/rescuetime" "RescueTime $PV" "/usr/share/icons/gnome/scalable/apps/preferences-system-time-symbolic.svg" "Office"
}

pkg_postinst(){
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}
