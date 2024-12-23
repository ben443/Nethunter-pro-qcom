#!/bin/bash

# Directory setup
KERNEL_DIR="$PWD/kernel"
DTB_DIR="$PWD/dtb"
OUT_DIR="$PWD/out"
TOOLS_DIR="$PWD/tools"

# Device specific configuration
DEVICE="r8q"
ARCH="arm64"
SUBARCH="arm64"
DEFCONFIG="vendor/r8q_defconfig"
DTB_FILE="qcom/sm8250-samsung-r8q.dtb"

# Create mkbootimg parameters file
cat > "$OUT_DIR/mkbootimg.cfg" << EOF
{
    "header_version": 2,
    "os_version": "11.0.0",
    "os_patch_level": "2024-12",
    "board": "SRPTH31C001",
    "pagesize": 4096,
    "cmdline": "console=ttyMSM0,115200n8 androidboot.hardware=qcom androidboot.memcg=1 lpm_levels.sleep_disabled=1 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 service_locator.enable=1 androidboot.usbcontroller=a600000.dwc3 swiotlb=2048 loop.max_part=7 cgroup.memory=nokmem,nosocket firmware_class.path=/vendor/firmware_mnt/image loop.max_part=7 androidboot.selinux=permissive buildvariant=eng",
    "base": "0x80000000",
    "kernel_offset": "0x8000",
    "ramdisk_offset": "0x1000000",
    "second_offset": "0x0",
    "tags_offset": "0x100",
    "dtb_offset": "0x20000000"
}
EOF

# Function to check if command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "Error: $1 is required but not installed."
        exit 1
    fi
}

# Check required tools
check_command mkbootimg
check_command dtc
check_command gcc

# Create boot.img
mkbootimg \
    --kernel "$KERNEL_DIR/Image.gz" \
    --ramdisk "$OUT_DIR/initramfs.cpio.gz" \
    --dtb "$DTB_DIR/$DTB_FILE" \
    --header_version 2 \
    --os_version 11.0.0 \
    --os_patch_level 2024-12 \
    #--board SRPTH31C001 \
    --pagesize 4096 \
    --cmdline "console=ttyMSM0,115200n8 androidboot.hardware=qcom androidboot.memcg=1 lpm_levels.sleep_disabled=1 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 service_locator.enable=1 androidboot.usbcontroller=a600000.dwc3 swiotlb=2048 loop.max_part=7 cgroup.memory=nokmem,nosocket firmware_class.path=/vendor/firmware_mnt/image loop.max_part=7 androidboot.selinux=permissive buildvariant=eng" \
    --base 0x80000000 \
    --kernel_offset 0x8000 \
    --ramdisk_offset 0x1000000 \
    --second_offset 0x0 \
    --tags_offset 0x100 \
    --dtb_offset 0x20000000 \
    --output "$OUT_DIR/boot.img"

echo "Boot image created at $OUT_DIR/boot.img"
