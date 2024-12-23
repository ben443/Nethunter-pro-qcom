# In your nethunter_r8q directory
mkdir -p ramdisk
cd ramdisk

# Create basic structure
mkdir -p {bin,sbin,etc,proc,sys,dev}

# Create init script
cat > init << 'EOF'
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev

# Mount root filesystem
mkdir /mnt
mount -t ext4 /dev/mmcblk0p65 /mnt

# Switch root
exec switch_root /mnt /sbin/init
EOF

chmod +x init

# Create the initramfs
find . | cpio -H newc -o | gzip > ../out/initramfs.cpio.gz
cd ..
