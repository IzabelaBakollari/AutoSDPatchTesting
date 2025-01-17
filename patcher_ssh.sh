#!/bin/bash

# This script patches the kernel-automotive-9 kernel source tree, builds/installs it, and sets it as the default boot kernel on the remote host

export patch_file=$1
cd /home/Camera/PatchTesting/kernel-automotive-9
export KERNELVERSION=$(make kernelversion)$(cat localversion-rt)

# confige .config ---- make sure that the config file exists in /boot
sudo cp /boot/config-* .config

# apply patch
sudo patch -p1 < ../linux/$patch_file

# build and install patched kernel
sudo make olddefconfig
sudo make -j$(nproc) && sudo make modules_install -j$(nproc)
sudo make install

# change permissions on the new boot image
cd /boot
sudo chmod 744 vmlinuz*$KERNELVERSION*

# set default kernel
sudo grubby --set-default=1
