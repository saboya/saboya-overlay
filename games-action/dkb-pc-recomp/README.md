# DKB PC Recomp

`games-action/dkb-pc-recomp` installs the Linux source-based command-line installer,
not a precompiled game. No Nintendo game files are downloaded or included.

```sh
emerge --ask games-action/dkb-pc-recomp
dkb-pc-recomp-setup --nup /path/to/game.nup --dest "$HOME/Games/dkb"
```

Alternatively, use an already dumped ExeFS and RomFS:

```sh
dkb-pc-recomp-setup --exefs /path/to/exefs --romfs /path/to/romfs \
    --dest "$HOME/Games/dkb" --jobs 6
```

Supported game versions are base **1.0.0** and update **3.2.0**. With a `.nup`, the
newest supported update is selected by default; `--nup-package base` selects the
base game. Supply your own legally obtained dump.

Run setup as your regular user, **not root**. The installer uses Gentoo's Python
packages, compiler, libraries and .NET 10 SDK; it does not bootstrap uv or pip.
The shader translator is built on first setup and `dotnet publish` needs network
access to restore NuGet packages. Game compilation also happens at setup time,
outside Portage's sandbox.

Temporary builds and logs default to `${XDG_CACHE_HOME:-$HOME/.cache}/dkb-pc-recomp`;
use `--temp /path/on/a/large/disk` to override this. The destination holds the built
`dkb` executable, game data, settings, caches and saves. Start it with:

```sh
cd "$HOME/Games/dkb"
./dkb
```

Re-run setup with `--dest` to resume, or after upgrading this package to rebuild
using the new sources. User-created games and saves are not managed or removed by
Portage. See `dkb-pc-recomp-setup --help` for all options.

Upstream requires Linux **6.7+**, an **AVX2**-capable x86-64 CPU, a **Vulkan 1.3**
GPU/driver, and substantial free disk space. At least **16 GiB RAM plus swap** is
needed; **32 GiB** is recommended. Linux support is a preview: crashes, missing
effects and GPU-specific problems remain.
