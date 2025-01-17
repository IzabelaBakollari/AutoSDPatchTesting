# Purpose
To test the effect of most kernel patches from https://github.com/clearlinux-pkgs/linux on the boot-time of the CentOS Automotive SIG's AutoSD [kernel](https://gitlab.com/CentOS/automotive/src/kernel/kernel-automotive-9).

## Structure
Each patch is applied on the pi remotely via ssh. The local x86_64 machine, in my case, is running Linux fedora 5.19.4 and the remote host (RPi4) is running AutoSD. You can find the image [here](https://autosd.sig.centos.org/AutoSD-9/nightly/non-sample-images/).

## Process
main.sh calls expect_pswd.exp (the expect script is generated by autoexpect, makes it easier to deal with auto-password prompts when starting a new ssh session)
expect_pswd.exp calls patcher_main.sh
patcher_main.sh opens an ssh session to the remote host and feeds it patcher_ssh.sh
patcher_main.sh calls sut_boottest.py
patcher_main.sh opens an ssh session to the remote host and feeds it patcher_rm_ssh.sh

1. A patch gets applied to the kernel source
2. Kernel source is built
3. Modules are installed
4. Compiled kernel is installed
5. New kernel is set as default boot kernel
6. Remote host gets rebooted and boot time is recorded via sut_boottest.py, which is written by John Harrigan at https://github.com/jharriga/BootTime. Test result file is written to pwd.
7. Last patch to the kernel source is reverted
8. Most recently installed kernel and all files relating to it, in /boot and /lib/modules, are deleted. Grub entry for most recent kernel is removed and default is set to the initially used kernel

Steps 1-8 are repeated for every patch.

NOTE: when the grub entries are modified, the script assumes that your initial kernel is at index=0 and will write the newly installed kernel to index=1. It is advised that you use caution and go through the code to make sure the dangerous operations are clear to you. If you start this script with more than one kernel installed to /boot on your remote host, the grub menu modification will behave unexpectedly and might lock you out of your device. Be very careful using this script on a remote host that has important data on it. Reference patcher_rm_ssh.sh for how the cleaning process works.

## Usage
In order to run the script safely, make sure to follow the prerequisite steps.

### Prereqs
1. patches.txt needs to be populated with the patches you want to be applied
2. The user, host, and password need to be configured properly in expect_pswd.exp, patcher_main.sh, and sut_boottest.py
3. The remote host should only have one kernel installed in /boot and the grub menu (see NOTE above, under the Process tab)
4. The remote host needs to have a kernel source repo and the path to it needs to be modified in patcher_ssh.sh and patcher_rm_ssh.sh (in this case the kernel source used is https://gitlab.com/CentOS/automotive/src/kernel/kernel-automotive-9)
5. The remote host needs to have a repo with the appropriate patches, modify the path to it in patcher_ssh.sh and patcher_rm_ssh.sh (in this case the patched used are from https://github.com/clearlinux-pkgs/linux)
6. Make sure that you have grubby installed on your remote host

### To Run
./main.sh
