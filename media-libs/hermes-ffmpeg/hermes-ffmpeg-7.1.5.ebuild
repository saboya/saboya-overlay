# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="Isolated static FFmpeg/CBS SDK for the Hermes streaming host"
HOMEPAGE="https://ffmpeg.org/ https://github.com/MrOz59/Hermes"
SRC_URI="https://ffmpeg.org/releases/ffmpeg-${PV}.tar.xz"
S="${WORKDIR}/ffmpeg-${PV}"

# CBS is a private API: consumers must use exactly the matching SDK version.
LICENSE="GPL-2+ LGPL-2.1+"
SLOT="7/${PV}"
KEYWORDS="~amd64"
IUSE="+vaapi"
RESTRICT="test"

RDEPEND="
	media-libs/x264:=
	vaapi? ( media-libs/libva:= )
"
DEPEND="
	${RDEPEND}
	=media-libs/nv-codec-headers-13*
"
BDEPEND="
	dev-lang/nasm
	virtual/pkgconfig
"

src_configure() {
	local sdk="${EPREFIX}/usr/$(get_libdir)/hermes-ffmpeg/${SLOT%%/*}"
	local args=(
		--prefix="${sdk}"
		--libdir="${sdk}/lib"
		--incdir="${sdk}/include"
		--cc="$(tc-getCC)"
		--cxx="$(tc-getCXX)"
		--ar="$(tc-getAR)"
		--nm="$(tc-getNM)"
		--ranlib="$(tc-getRANLIB)"
		--pkg-config="$(tc-getPKG_CONFIG)"
		--extra-cflags="${CFLAGS}"
		--extra-ldflags="${LDFLAGS}"
		--disable-all
		--disable-autodetect
		--disable-doc
		--disable-programs
		--disable-debug
		--disable-stripping
		--disable-shared
		--enable-static
		--enable-pic
		--enable-avcodec
		--enable-avutil
		--enable-swscale
		--enable-gpl
		--enable-libx264
		--enable-encoder=libx264
		# Keep the CBS implementations in libavcodec, not a separate duplicate library.
		--enable-bsf=h264_metadata,hevc_metadata,av1_metadata
		$(use_enable vaapi)
		$(usev vaapi --enable-encoder=h264_vaapi,hevc_vaapi,av1_vaapi)
		--enable-ffnvcodec
		--enable-nvenc
		--enable-encoder=h264_nvenc,hevc_nvenc,av1_nvenc
	)
	if tc-is-cross-compiler; then
		args+=( --enable-cross-compile --arch="$(tc-arch-kernel)" --target-os=linux --cross-prefix="${CHOST}-" --host-cc="$(tc-getBUILD_CC)" )
	fi
	./configure "${args[@]}" || die
}

src_install() {
	local sdk="/usr/$(get_libdir)/hermes-ffmpeg/${SLOT%%/*}"
	emake DESTDIR="${D}" install

	# Upstream only installs public headers. CBS also needs its private, generated
	# configuration and transitive internal headers, all isolated under this SDK.
	insinto "${sdk}/include"
	doins config.h config_components.h
	local component header
	for component in libavcodec libavutil libswscale; do
		while IFS= read -r -d '' header; do
			insinto "${sdk}/include/${header%/*}"
			doins "${header}"
		done < <(find "${component}" -type f -name '*.h' -print0)
	done

	local pc="${T}/hermes-ffmpeg-${SLOT%%/*}.pc"
	cat > "${pc}" <<-EOF || die
		prefix=${EPREFIX}${sdk}
		sdkdir=\${prefix}
		libdir=\${prefix}/lib
		includedir=\${prefix}/include
		Name: hermes-ffmpeg-${SLOT%%/*}
		Description: Isolated static FFmpeg SDK with private CBS headers
		Version: ${PV}
		Libs: -L\${libdir} -lavcodec -lswscale -lavutil -lx264 -lm -ldl -pthread $(usev vaapi '-lva -lva-drm')
		Cflags: -I\${includedir}
	EOF
	insinto /usr/share/pkgconfig
	doins "${pc}"
	dodoc README.md COPYING.GPLv2 COPYING.LGPLv2.1
}
