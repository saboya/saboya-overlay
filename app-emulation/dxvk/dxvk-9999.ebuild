# Distributed under the terms of the GNU General Public License v2

EAPI="6"

MULTILIB_COMPAT=( abi_x86_{32,64} )

inherit eutils meson multilib-minimal

DESCRIPTION="Vulkan-based D3D11 implementation for Linux / Wine"
HOMEPAGE="https://github.com/doitsujin/dxvk"

LICENSE="ZLIB"
SLOT="0"

if [[ ${PV} == "9999" ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/doitsujin/${PN}.git"
	SRC_URI=""
	KEYWORDS=""
else
	SRC_URI="https://github.com/doitsujin/dxvk/archive/v${PV}.tar.gz"
	KEYWORDS="-* ~amd64 ~x86 ~x86-fbsd"
fi


IUSE="+abi_x86_32 +abi_x86_64 +buildinfo"

REQUIRED_USE="
	|| ( abi_x86_32 abi_x86_64 )
"

RDEPEND="
	virtual/wine
	|| (
		app-emulation/wine-vanilla[vulkan,${MULTILIB_USEDEP}]
		app-emulation/wine-staging[vulkan,${MULTILIB_USEDEP}]
		app-emulation/wine-any[vulkan,${MULTILIB_USEDEP}]
	)
"

DEPEND="
	>=dev-util/glslang-6.2.2596
	>=dev-util/meson-0.43
"

PATCHES=( "${FILESDIR}/Adding-env-var-for-opting-into-24-bit-Vulkan-formats.patch" )

src_prepare() {
	if [ ${PV} == "9999" ] && use buildinfo; then
		local hudpatch="${T}/buildinfo.patch"

		cp "${FILESDIR}/hud-Add-new-option-buildinfo.patch" $hudpatch

		local buildinfo=${PV}

		if [[ ${PV} == "9999" ]]; then
			buildinfo=$(git-r3_peek_remote_ref | cut -c1-7)
		fi

		sed -i "s/__BUILDINFO__/${buildinfo}/" $hudpatch || die

		PATCHES+=($hudpatch)
	fi
	default
}

multilib_src_configure() {
	local arch=${MULTILIB_ABI_FLAG##*_}
	local crossfile="${S}/build-win${arch}.txt"

	# Skips executable sanity check, errors out on 64-bit build.
	# Let's hope our compilers are not broken.
	sed -i '/^exe_wrapper/d' "${crossfile}"

	local emesonargs=(
		--cross-file "${S}/build-win${arch}.txt"
		--prefix "${BUILD_DIR}/install"
		--unity on
		-Denable-tests=false
	)


	meson_src_configure

}


multilib_src_compile() {
	cd "${BUILD_DIR}"
	eninja install
}

multilib_src_install() {
	cd "${BUILD_DIR}/install/bin"

	insinto "${DESTREE}/$(get_libdir)/dxvk"
	doins	d3d11.dll \
		dxgi.dll \
		setup_dxvk.sh
}

multilib_src_install_all() {
	local dxvk_setup="${T}/dxvk_setup"
	cp "${FILESDIR}/dxvk_setup.sh" $dxvk_setup

	for ABI in $(multilib_get_enabled_abis)
	do
		local libdir="${DESTREE}/$(get_libdir)/dxvk"
		sed -i "s:__${ABI}__:$libdir:g" $dxvk_setup
	done

	dobin	$dxvk_setup

}
