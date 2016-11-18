# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

inherit git-r3

DESCRIPTION="Bots para conciliações bancárias"
HOMEPAGE="https://github.com/maxiwell/ofx-bot"
EGIT_REPO_URI="https://github.com/maxiwell/ofx-bot.git"
SRC_URI=""

RDEPEND="|| ( virtual/jre:1.7 virtual/jre:1.8 )"
DEPEND="itau? (
	>=dev-lang/ghc-7.10
	>=dev-haskell/haskell-platform-2014.2.0.0
	dev-haskell/webdriver
	dev-haskell/executable-path
)
nubank? (
	>=dev-lang/ghc-7.10
	>=dev-haskell/haskell-platform-2014.2.0.0
	dev-haskell/webdriver
	dev-haskell/executable-path
	dev-haskell/tuple
)
bb? ( dev-python/selenium )
caixa? ( dev-python/selenium )
santander? ( dev-python/selenium )
|| ( www-client/firefox www-client/firefox-bin )"

REQUIRED_USE="|| ( nubank itau bb caixa santander )"
IUSE="+nubank +itau bb caixa santander"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

SELENIUM_VERSION="2.46"
SELENIUM_JAR="selenium-server-standalone-${SELENIUM_VERSION}.0.jar"
SELENIUM_URI="http://selenium-release.storage.googleapis.com/${SELENIUM_VERSION}/${SELENIUM_JAR}"

src_compile() {
	cd  ${WORKDIR}/${PF}/itau/
	./build.sh

	cd  ${WORKDIR}/${PF}/nubank/
	./build.sh
}

src_install() {
	into /opt
	exeinto /opt/bin

	if use nubank; then doexe ${WORKDIR}/${PF}/csv-nubank; fi
	if use itau; then doexe ${WORKDIR}/${PF}/ofx-itau; fi
	if use bb; then doexe ${WORKDIR}/${PF}/ofx-bb.py; fi
	if use caixa; then doexe ${WORKDIR}/${PF}/ofx-caixa.py; fi
	if use santander; then doexe ${WORKDIR}/${PF}/ofx-santander.py; fi

	if use nubank || use itau; then
		wget -P ${WORKDIR}/${PF} ${SELENIUM_URI}
		dobin ${WORKDIR}/${PF}/${SELENIUM_JAR}
	fi


}
