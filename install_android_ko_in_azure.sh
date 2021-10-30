# Download azure compiled ko (official)
PKG=linux-modules-extra-`uname -r`
apt download linux-modules-extra-`uname -r`

# take only what you need
DEB=`ls -1 *$PKG*.deb | head -1`
ar x $DEB
mkdir kernel_drivers
tar -xJf data.tar.xz -C kernel_drivers

BINDER=`find . | grep binder`
ASHMEM=`find . | grep ashmem`
#./lib/modules/5.8.0-1041-azure/kernel/drivers/android/binder_linux.ko
#./lib/modules/5.8.0-1041-azure/kernel/drivers/staging/android/ashmem_linux.ko

#https://www.tecmint.com/load-and-unload-kernel-modules-in-linux/
# copy to modules and insmod
#sudo insmod /lib/modules/5.8.0-1041-azure/kernel/drivers/android/binder_linux.ko
