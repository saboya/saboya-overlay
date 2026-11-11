# Lichii packaging

## Current versions

- `150`: upstream's latest published release (`build-150`), checked 2026-11-11.
- `9999`: the moving `nx2` branch. Build-system audit/configure tested at
  `4d884cbb5b1a1558a4011edae4acb2e688bf2fc1`.
- `94`: retained older release; its upstream tag was mislabeled as build 94.

## NX archives

Build 150 and newer have an optional NX archive converter/editor in the Qt
frontend. The default-enabled `nxconvert` flag uses `dev-libs/nxformat`, built
from source with checksummed, fetch-phase Cargo dependencies. No prebuilt SDK
is downloaded during Lichii's configure phase. Disabling `nxconvert` does not
disable loading `.nx` games.

For converter support, accept `~amd64` for `dev-libs/nxformat` as well as
`games-emulation/lichii`. To omit it, set:

```text
games-emulation/lichii -nxconvert
```

Build 150 links nxformat's shared library. Current live sources instead use
its static archive without bundled Zstandard, linking Lichii's pinned zstd.
The separate nxformat package provides both, and its shared library uses
system Zstandard. The package does not include the standalone NXConvert GUI.

## Build dependencies

The newer ebuilds use system xxHash headers and require fmt 10 or later.
Qt Charts is still required by build 150, but no longer by the live branch.
Existing system-library choices remain, including zlib-ng/minizip-ng in
compatibility mode. Upstream's pinned zstd and zbic remain separately fetched
build inputs, with optional ReShade similarly fetched and patched before use.
The application's updater remains disabled; use Portage to update it.
