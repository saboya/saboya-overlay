# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=6.2
inherit rocm
inherit cmake
inherit go-module systemd toolchain-funcs

DESCRIPTION="Get up and running with Llama 3, Mistral, Gemma, and other language models"
HOMEPAGE="https://ollama.com"
SRC_URI="
	https://github.com/ollama/ollama/archive/refs/tags/v$PV.tar.gz
	https://gitlab.phys-el.ru/gentoo/phackerlay-distfiles/-/raw/master/${P}-deps.tar.xz
"

A='
PV=0.17.0
wget https://github.com/ollama/ollama/archive/refs/tags/v$PV.tar.gz && \
tar -xf v$PV.tar.gz && \
rm v$PV.tar.gz && \
cd ollama-$PV/ && \
GOMODCACHE="${PWD}"/go-mod go mod download -modcacherw && \
XZ_OPT="-T0 -9" tar -acf ollama-$PV-deps.tar.xz go-mod && \
mv ollama-$PV-deps.tar.xz ../../../distfiles/ && \
cd .. && \
rm -rf ollama-${PV}
'

KEYWORDS="~amd64"

LICENSE="MIT"
SLOT="0"

X86_CPU_FLAGS=(
	sse4_2
	avx
	f16c
	avx2
	bmi2
	fma3
	avx512f
	avx512vbmi
	avx512_vnni
	avx_vnni
)

CPU_FLAGS=( "${X86_CPU_FLAGS[@]/#/cpu_flags_x86_}" )
IUSE="${CPU_FLAGS[*]} blas rocm"

RESTRICT="test"

COMMON_DEPEND="
	blas? (
		virtual/blas
	)
	rocm? (
		>=sci-libs/hipBLAS-5.5:=[${ROCM_USEDEP}]
	)
"

DEPEND="
	${COMMON_DEPEND}
	>=dev-lang/go-1.23.4
"

RDEPEND="
	${COMMON_DEPEND}
	acct-group/${PN}
	acct-user/${PN}
"

PATCHES=(
	"${FILESDIR}/use-GNUInstallDirs.patch"
)
#	"${FILESDIR}/search-so-in-ggml-paths-first.patch"

pkg_pretend() {
	if use amd64; then
		if use cpu_flags_x86_f16c && use cpu_flags_x86_avx2 && use cpu_flags_x86_fma3 && ! use cpu_flags_x86_bmi2; then
			ewarn
			ewarn "CPU_FLAGS_X86: bmi2 not enabled."
			ewarn "  Not building haswell runner."
			ewarn "  Not building skylakex runner."
			ewarn "  Not building icelake runner."
			ewarn "  Not building alderlake runner."
			ewarn
			if grep bmi2 /proc/cpuinfo > /dev/null; then
				ewarn "bmi2 found in /proc/cpuinfo"
				ewarn
			fi
		fi
	fi
}

INSTALL_PREFIX="/opt/ollama"

src_prepare() {
	cmake_src_prepare

	sed \
		-e "/set(GGML_CCACHE/s/ON/OFF/g" \
		-e "/PRE_INCLUDE_REGEXES.*cu/d" \
		-e "/PRE_INCLUDE_REGEXES.*hip/d" \
		-i CMakeLists.txt || die sed

	sed \
		-e "s/ -O3//g" \
		-i ml/backend/ggml/ggml/src/ggml-cpu/cpu.go || die sed

	# fix library location
	sed \
		-e "s#lib/ollama#$(get_libdir)/ollama#g" \
		-i CMakeLists.txt || die sed

	sed \
		-e "s#\"..\", \"lib\"#\"..\", \"$(get_libdir)\"#" \
		-e "s#\"lib/ollama\"#\"$(get_libdir)/ollama\"#" \
		-i \
			ml/backend/ggml/ggml/src/ggml.go \
			ml/path.go \
		|| die

	if use amd64; then
		if
			! use cpu_flags_x86_sse4_2; then
			sed -e "/ggml_add_cpu_backend_variant(sse42/s/^/# /g" -i ml/backend/ggml/ggml/src/CMakeLists.txt || die
			# SSE42)
		fi
		if
			! use cpu_flags_x86_sse4_2 ||
			! use cpu_flags_x86_avx; then
			sed -e "/ggml_add_cpu_backend_variant(sandybridge/s/^/# /g" -i ml/backend/ggml/ggml/src/CMakeLists.txt || die
			# SSE42 AVX)
		fi
		if
			! use cpu_flags_x86_sse4_2 ||
			! use cpu_flags_x86_avx ||
			! use cpu_flags_x86_f16c ||
			! use cpu_flags_x86_avx2 ||
			! use cpu_flags_x86_bmi2 ||
			! use cpu_flags_x86_fma3; then
			sed -e "/ggml_add_cpu_backend_variant(haswell/s/^/# /g" -i ml/backend/ggml/ggml/src/CMakeLists.txt || die
			# SSE42 AVX F16C AVX2 BMI2 FMA)
		fi
		if
			! use cpu_flags_x86_sse4_2 ||
			! use cpu_flags_x86_avx ||
			! use cpu_flags_x86_f16c ||
			! use cpu_flags_x86_avx2 ||
			! use cpu_flags_x86_bmi2 ||
			! use cpu_flags_x86_fma3 ||
			! use cpu_flags_x86_avx512f; then
			sed -e "/ggml_add_cpu_backend_variant(skylakex/s/^/# /g" -i ml/backend/ggml/ggml/src/CMakeLists.txt ||  die
			# SSE42 AVX F16C AVX2 BMI2 FMA AVX512)
		fi
		if
			! use cpu_flags_x86_sse4_2 ||
			! use cpu_flags_x86_avx ||
			! use cpu_flags_x86_f16c ||
			! use cpu_flags_x86_avx2 ||
			! use cpu_flags_x86_bmi2 ||
			! use cpu_flags_x86_fma3 ||
			! use cpu_flags_x86_avx512f ||
			! use cpu_flags_x86_avx512vbmi ||
			! use cpu_flags_x86_avx512_vnni; then
			sed -e "/ggml_add_cpu_backend_variant(icelake/s/^/# /g" -i ml/backend/ggml/ggml/src/CMakeLists.txt || die
			# SSE42 AVX F16C AVX2 BMI2 FMA AVX512 AVX512_VBMI AVX512_VNNI)
		fi
		if
			! use cpu_flags_x86_sse4_2 ||
			! use cpu_flags_x86_avx ||
			! use cpu_flags_x86_f16c ||
			! use cpu_flags_x86_avx2 ||
			! use cpu_flags_x86_bmi2 ||
			! use cpu_flags_x86_fma3 ||
			! use cpu_flags_x86_avx_vnni; then
			sed -e "/ggml_add_cpu_backend_variant(alderlake/s/^/# /g" -i ml/backend/ggml/ggml/src/CMakeLists.txt || die
			# SSE42 AVX F16C AVX2 BMI2 FMA AVX_VNNI)
		fi

		# ml/backend/ggml/ggml/src/CMakeLists.txt
	fi

	if use rocm; then
		# --hip-version gets appended to the compile flags which isn't a known flag.
		# This causes rocm builds to fail because -Wunused-command-line-argument is turned on.
		# Use nuclear option to fix this.
		# Disable -Werror's from go modules.
		find "${S}" -name ".go" -exec sed -i "s/ -Werror / /g" {} + || die
	fi
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}
		-DGGML_CCACHE="no"
		-DGGML_BLAS="$(usex blas)"
	)

	if use blas; then
		mycmakeargs+=(
			-DGGML_BLAS_VENDOR="Generic"
		)
	fi

	if use rocm; then
		mycmakeargs+=(
			-DCMAKE_HIP_ARCHITECTURES="$(get_amdgpu_flags)"
			-DCMAKE_HIP_PLATFORM="amd"
			# ollama doesn't honor the default cmake options
			-DAMDGPU_TARGETS="$(get_amdgpu_flags)"
		)

		local -x HIP_PATH="${ESYSROOT}/usr"

		check_amdgpu
	else
		mycmakeargs+=(
			-DCMAKE_HIP_COMPILER="NOTFOUND"
		)
	fi

	cmake_src_configure
}

src_compile() {
	VERSION=$(
		git describe --tags --first-parent --abbrev=7 --long --dirty --always \
		| sed -e "s/^v//g"
	)
	GOFLAGS+=" '-ldflags=-w -s \"-X=github.com/ollama/ollama/version.Version=$VERSION\" \"-X=github.com/ollama/ollama/server.mode=release\"'"

	ego build

	cmake_src_compile
}

src_install() {
	into ${INSTALL_PREFIX}
	dobin ollama
	dosym ${EPREFIX}${INSTALL_PREFIX}/bin/ollama /usr/bin/ollama

	cmake_src_install

	newinitd "${FILESDIR}/ollama.init" "${PN}"
	newconfd "${FILESDIR}/ollama.confd" "${PN}"

	systemd_dounit "${FILESDIR}/ollama.service"
}

pkg_preinst() {
	keepdir /var/log/ollama
	fperms 750 /var/log/ollama
	fowners "${PN}:${PN}" /var/log/ollama
}
