# Hermes streaming host

The release ebuild packages <https://github.com/MrOz59/Hermes> v0.7.0;
the live (`9999`) ebuild tracks `main`.
It is unrelated to Gentoo's `dev-util/hermes` testing framework.

## Install

Accept the release ebuild in `/etc/portage/package.accept_keywords`:

```text
=net-misc/hermes-0.7.0 ~amd64
dev-libs/libdisplaydevice ~amd64
dev-libs/libvirtualhid-hermes ~amd64
net-libs/moonlight-enet ~amd64
gui-libs/wlr-protocols ~amd64
media-libs/hermes-ffmpeg ~amd64
```

Then install it:

```sh
emerge --ask net-misc/hermes
```

To build from an existing local clone without changing the ebuild:

```sh
EGIT_OVERRIDE_REPO_MROZ59_HERMES=/home/saboya/projects/oss/Hermes \
    ebuild net-misc/hermes/hermes-9999.ebuild clean install
```

The `install` phase only stages files; it does not merge them onto the system.
Dependencies must already be installed when testing with `ebuild`.

## First run

Run Hermes in the desktop user's session, never as root:

```sh
hermes
```

With `USE=systemd`, the package also installs a user service:

```sh
systemctl --user enable --now hermes.service
```

Open <https://localhost:47990> to create credentials and pair Moonlight/Hestia.
The initial certificate is self-signed. Do not expose the administration UI
directly to the public internet.

### Building without the browser UI

Add this to `/etc/portage/package.use/hermes`:

```text
net-misc/hermes -webui
```

Then rebuild Hermes. This skips npm entirely, removes the Node.js build
dependency, and does not install the browser pages. The streaming host and
HTTPS administration API are still built; this is not a way to disable the
administration server or its authentication.

Without the pages, configuration and pairing need to be managed through
`~/.config/hermes/hermes.conf`, `apps.json`, and the API. Set API credentials
with `hermes --creds USER PASSWORD` while the host is stopped (the password is
visible in the command's process arguments). Pairing can then be approved
through `POST /api/pin` with HTTP Basic authentication, for example:

```sh
curl --insecure --user USER --header 'Content-Type: application/json' \
    --data '{"pin":"1234","name":"Steam Deck"}' https://localhost:47990/api/pin
```

Use the PIN displayed by Moonlight; curl prompts for the password. The
`--insecure` option here accommodates the default self-signed local certificate.
The browser UI is recommended if you prefer interactive configuration. With
`webui` enabled, npm's current unpack-time downloads still require network
access; a locked, fetch-phase dependency scheme has not yet been implemented.

For streaming an existing monitor, select `virtual_display_backend = none`.
Stop any other Sunshine/Apollo host using the same streaming ports.

Virtual controllers need the `uinput` and `uhid` kernel modules and access to
their device nodes. The package installs udev rules and a modules-load file;
after the first install, load the modules or reboot. On systemd desktops,
udev's `uaccess` rules grant access to the active local user.

## Scope

- KMS capture (`USE=kms`) grants `CAP_SYS_ADMIN` to `/usr/bin/hermes` through
  Gentoo's `filecaps` support. Disable `kms` to avoid that capability if another
  capture backend works for your compositor.
- `media-libs/hermes-ffmpeg` provides a separately packaged static FFmpeg/CBS
  SDK under `/usr/lib64/hermes-ffmpeg/7` (or the architecture's library dir).
  It does not replace the system FFmpeg installation. Hermes no longer builds
  FFmpeg itself. Software H.264 and NVENC encoders are built, with VAAPI encoders
  controlled by matching `USE=vaapi` on Hermes and the SDK.
- CBS headers are private, so Hermes pins the exact SDK version and records a
  subslot rebuild dependency. Updating it requires a compatibility/build check;
  FFmpeg security updates must also be applied to this separate SDK package.
- `USE=cuda` adds CUDA/NvFBC capture and requires a compatible CUDA compiler.
- NVENC headers come from Gentoo's `media-libs/nv-codec-headers`, rather than
  an embedded copy. The wlr protocol XML comes from `gui-libs/wlr-protocols`.
- `dev-libs/libvirtualhid-hermes`, `dev-libs/libdisplaydevice`, and
  `net-libs/moonlight-enet` provide separate installed static SDKs. The Hermes
  HID fork uses its own SDK directory, and Moonlight ENet uses distinct headers
  and an archive name so it can coexist with standard ENet. These snapshots
  are pinned because upstream does not promise interchangeable APIs.
- The npm dependencies are downloaded during `src_unpack`; configure and
  compile run offline. Neither ebuild currently provides a separately versioned
  npm dependency archive or lockfile; npm's transitive dependency resolution
  can therefore change even for the release ebuild. All C/C++ source archives
  and release submodule revisions are pinned and verified by the Manifest.
- The experimental PyroWave codec and privileged card/session brokers are not
  included. Their automatic dependency detection is disabled.
- Hermes-KMS and EVDI kernel drivers are **not** installed by Hermes itself.
  This overlay provides `x11-drivers/hermes-kms-0.4.1` separately, with module
  defaults and udev access rules for existing-session virtual displays; see
  `x11-drivers/hermes-kms/README.md`. It is not loaded during installation,
  but its modules-load file requests loading on subsequent boots.
  Existing-monitor streaming does not need a virtual-display driver.
