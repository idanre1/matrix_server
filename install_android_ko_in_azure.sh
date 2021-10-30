# Download azure compiled ko (official)
PKG=linux-modules-extra-`uname -r`
apt download linux-modules-extra-`uname -r`

# take only what you need
DEB=`ls -1 *$PKG*.deb | head -1`
ar x $DEB
mkdir kernel_drivers
tar -xJf data.tar.xz -C kernel_drivers
