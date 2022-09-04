# NetHunter Pro recipes

A set of [debos](https://github.com/go-debos/debos) recipes for building a
Kali Linux based image for mobile phones, initially targetting Pine64's PinePhone.

Prebuilt images are available [here](https://www.kali.org/get-kali/#kali-mobile).

The default user is `kali` with password `1234`.

## Build

To build the image, you need to have `debos` and `bmaptool`. On a Kali Linux
system, install these dependencies by typing the following command in a terminal:

```
sudo apt install debos bmap-tools f2fs-tools
```

If you want to build with EXT4 filesystem f2fs-tools is not required.

The build system will cache and re-use it's output files. To create a fresh build
remove `*.tar.gz`, `*.sqfs` and `*.img` before starting the build.

Then simply browse to the `kali-nethunter-pro` folder and execute `./build.sh`.

You can use `./build.sh -d` to use the docker version of `debos`.

### Building QEMU image

You can build a QEMU x86_64 image by adding the `-t amd64` (UEFI) or
`-t amd64-legacy` (BIOS) flags to `build.sh`

The resulting files are raw images. You can start qemu like so:

```
qemu-system-x86_64 -drive format=raw,file=<imagefile.img> -enable-kvm -cpu host -vga virtio -m 2048 -smp cores=4 -bios <uefi-firmware>
```
If you have built the BIOS image you can drop the `-bios <uefi-firmware>` flag.
On a gentoo system f.e. the uefi firmware can be found under
`/usr/share/edk2-ovmf/OVMF_CODE.fd`

You may also want to convert the raw image to qcow2 format
and resize it like this:

```
qemu-img convert -f raw -O qcow2 <raw_image.img> <qcow_image.qcow2>
qemu-img resize -f qcow2 <qcow_image.qcow2> +20G
```

## Install

Insert a MicroSD card into your computer, and type the following command:

```
sudo dd if=<image> of=/dev/<sdcard> bs=1M
```

*Note: Make sure to use your actual SD card device, such as `mmcblk0` instead of
`<sdcard>`.*

**CAUTION: This will format the SD card and erase all its contents!!!**

Note: When booting NetHunter Pro from sdcard (as opposed to installing from sdcard),
      remember to resize your sd-card first or you'll run out of space very quickly:

```
sudo parted /dev/<sdcard>
(parted) resizepart 2 100%
(parted) quit
sudo resize2fs /dev/<sdcard><partition>
```

# License

This software is licensed under the terms of the GNU General Public License,
version 3.
