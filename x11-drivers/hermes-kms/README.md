# Hermes-KMS on Gentoo

`x11-drivers/hermes-kms-0.4.1` packages the released driver (UAPI 14), using
Gentoo's `linux-mod-r1` framework, not DKMS. It is intended for Hermes 0.7.0
and later, including GNOME Wayland's existing desktop session.

## Install

Accept the testing keyword in `/etc/portage/package.accept_keywords`:

```text
x11-drivers/hermes-kms ~amd64
```

Ensure `/usr/src/linux` points to the configured, built kernel you want to
target. The kernel needs DRM, DRM KMS helpers, DRM GEM shmem helpers, shared
DMA buffers, shmem, MMU and module support. Configfs is optional for the single
static virtual card; enable `CONFIG_CONFIGFS_FS` for dynamic configfs cards.

```sh
emerge --ask x11-drivers/hermes-kms
```

Gentoo distribution-kernel users can enable `dist-kernel` for integration with
kernel upgrades. Custom-kernel users should rebuild the package after a kernel
upgrade. Secure Boot may require `modules-sign` and an enrolled signing key;
the eclass handles module signing/compression rather than upstream's installer.

The package installs udev rules and the upstream read-only render-node ACL
helper. Those permissions keep generic GPU clients from choosing this virtual
device as a rendering GPU. Do not replace them with world-writable permissions
or install upstream's development ignore-seat rules: GNOME must see the card
on the active seat to adopt its connector.

## First run on GNOME Wayland with NVIDIA

Save your work first: this is an experimental out-of-tree DRM driver. With no
active stream, load the module as root:

```sh
modprobe hermes_kms initial_enabled=0 outputs=1
```

The same defaults are packaged for subsequent boot-time loading. `/etc`
modprobe configuration overrides `/usr/lib`, so check for stale settings that
enable the connector at boot. If an older version is already loaded, reboot
instead of forcing it out of a running compositor.

Run Hermes as your logged-in desktop user (not root). In
`~/.config/hermes/hermes.conf`, select:

```ini
virtual_display_backend = hermes_kms
encoder = nvenc
```

Request a virtual display in the application's/client's streaming settings as
well; choosing a driver alone does not request one. Start at 1280x800, 60 Hz,
SDR and keep the physical monitors enabled until you have a working stream.
Mutter activates the virtual output through its DisplayConfig D-Bus API.
The NVIDIA path still copies captured frames through CPU memory before NVENC;
the AMD/Intel zero-copy path is not available on NVIDIA in this release.

Basic diagnostics (the CLI is installed with `USE=tools`):

```sh
modinfo hermes_kms
cat /sys/module/hermes_kms/parameters/initial_enabled
hermes-kmsctl --help
journalctl -k -b | grep -i hermes
journalctl --user -u hermes.service -b
```

This package does not install the private-seat/session brokers, change your
kernel configuration, or load/unload the module during package installation.
It supports adding a virtual monitor to the existing GNOME session, not a
complete pre-login or independently isolated desktop setup.
