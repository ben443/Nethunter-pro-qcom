# Kali NetHunter Pro (Build-Script)

<!-- Upstream: https://salsa.debian.org/Mobian-team/mobian-recipes -->

[Kali NetHunter Pro](https://www.kali.org/get-kali/#kali-mobile) is a Mobile Penetration Testing Platform, based on GNU/Linux _(rather than [Kali NetHunter](https://www.kali.org/get-kali/#kali-mobile) which uses [Android](https://www.kali.org/docs/nethunter/))_.

[![Kali NetHunter Pro Logo](./images/kali-nethunterpro-logo-dragon-orange-transparent.png)](./images/kali-nethunterpro-logo-dragon-orange-transparent.png)

Pre-built images are available [here](https://www.kali.org/get-kali/#kali-mobile), otherwise you can build it yourself.

[This build-script](https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-pro) is a set of [debos](https://github.com/go-debos/debos) recipes for building a [Kali Linux](https://www.kali.org/) based image for mobile phones<!-- _(initially targeting Pine64's PinePhone, as well as supporting Pine64's PinePhonePro & Qualcomm's SDM845/SM7225)._-->

The [default user](https://www.kali.org/docs/introduction/default-credentials/) is `kali` with password `1234`.

## Setup

This could be built on any [Debian-based](https://www.debian.org/derivatives/) system but we recommend building on [Kali Linux](https://www.kali.org/).

There are two methods to install; bare metal or containers.

### Bare metal

The essential packages required to install are:

```console
sudo apt install git debos bmap-tools xz-utils
```

- - -

If you want to build an image for a Qualcomm-based device, additional packages are required, which you can install with the following command:

```console
sudo apt install android-sdk-libsparse-utils yq
```

- - -

If possible, its recommended to use hardware with KVM support:

```console
$ sudo apt install cpu-checker
[...]
$ kvm-ok
INFO: /dev/kvm exists
KVM acceleration can be used
$
$ sudo apt install qemu-system-x86
[...]
$ sudo adduser $( id -un ) libvirt
info: Adding user `kali' to group `libvirt' ...
$ sudo adduser $( id -un ) kvm
info: Adding user `kali' to group `kvm' ...
$
$ sudo reboot
```

_if KVM support isn't an option, install `user-mode-linux`_

- - -

Similarly, if you want to use F2FS for the root filesystem (which isn't such a good idea, as it has been known to cause corruption in the past), you'll need to install `f2fs-tools` as well.

```console
sudo apt install f2fs-tools
```

_**NOTE**: DNS resolution may break after installing the above package (`f2fs-tools`). To fix this, add a valid DNS resolver (e.g., `1.1.1.1`) to the file `/etc/systemd/resolved.conf` and then `sudo systemctl restart systemd-resolved.service`_

### Containers

The packages required to installed:

```console
sudo apt install git docker.io kali-archive-keyring
```

**You then need to add `-d` to build commands going forwards, e.g.: `./build.sh -d`.**

## Build

After everything has been prepared, simply, clone and browse to the `kali-nethunter-pro` directory and execute `./build.sh` (or `./build.sh -d`):

```console
git clone https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-pro.git
cd kali-nethunter-pro/
./build.sh
```

- - -

### Caching

The build system will cache and re-use it's output files.

To create a fresh build remove `*.tar.gz`, `*.sqfs` and `*.img` before starting the build.

- - -

## Examples/Help/Arguments

<!-- At the time of writing, there isn't a help script -h / --help / -?. Look at ./build.sh -->

```plaintext
-d         : Use docker

-t <VALUE> : Device to create (Default: pinephone)
             [pinephone/pinephonepro/sdm845/sm7225/amd64]

-c         : Enable encrypted root filesystem
-R <VALUE> : Set password for encrypted root filesystem

-v         : Enable verbose output
-D         : Enable debug output

-e <VALUE> : Set environment (Default: phosh)
             [phosh/plasma-mobile]
-F <VALUE> : Set filesystem (Default: ext4)
             [ext4/btrfs/f2fs]

-H <VALUE> : Set hostname (Default: kali)
-V <VALUE> : Set version (Default: YYYYMMDD)

-u <VALUE> : Set username (Default: kali)
-p <VALUE> : Set password (Default: 1234)

-i         : Only create image (Skip creating rootfs)
-z         : Compress output
-b         : Skip creating the block map (bmap)
-g <VALUE> : GPG sign sha256sums output


-s         : Enable SSH
-Z         : Enable ZRAM
-r         : Enable miniramf

-f <VALUE> : Set a FTP proxy (Default: none)
-h <VALUE> : Set a HTTP proxy (Default: none)

-M <VALUE> : Set APT mirror to use (Default: http://http.kali.org/kali)
-m <VALUE> : Set memory

-x <VALUE> : Which branch to use (Default: kali-rolling)
```
<!--
Unsupported options:
-o         : Create installer image
-S <VALUE> : Which OS to base the image on
-C         : Enable contrib component (Default: true)
-->

- - -

## Testing

If you want to test an image outside of running it directly on the device, a raw image can created to work with QEMU.

You can build a QEMU x86_64 image by adding the `-t amd64` flag to `build.sh`:

```console
./build.sh -t amd64

sudo apt install qemu-system-x86 ovmf

qemu-system-x86_64 \
  -drive format=raw,file="/path/to/nethunterpro-*-amd64-phosh.img" \
  -enable-kvm \
  -cpu host \
  -vga virtio \
  -m 2048 \
  -smp cores=4 \
  -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.fd
```

UEFI firmware files are available in Debian thanks to the [OVMF](https://packages.debian.org/sid/all/ovmf/filelist) package.
Comprehensive explanation about firmware files can be found at [OVMF project's repository](https://github.com/tianocore/edk2/tree/master/OvmfPkg).

- - -

You may also want to convert the raw image to qcow2 format and resize it like this:

```console
qemu-img convert -f raw -O qcow2 <raw_image.img> <qcow_image.qcow2>
qemu-img resize -f qcow2 <qcow_image.qcow2> +20G
```

## Install

Insert a MicroSD card into your computer, and type the following command:

```console
sudo dd if=<image> of=/dev/<sdcard> bs=1M
```

_Note: Make sure to use your actual SD card device, such as `mmcblk0` instead of `<sdcard>`._

**CAUTION: This will format the SD card and erase all its contents!!!**

### Install via Windows

You can use [balenaEtcher](https://etcher.balena.io/) to install the image downloaded onto the SD card. Start etcher and select the image file, target (which would be the SD card) and then "Flash".

## License

This software is licensed under the terms of the [GNU General Public License, version 3](https://www.kali.org/docs/policy/kali-linux-open-source-policy/).
