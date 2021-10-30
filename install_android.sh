aptyes='sudo DEBIAN_FRONTEND=noninteractive apt-get -y '

# Install DKMS package from PPA
$aptyes update
$aptyes install linux-headers-generic dkms

# kernel headers
cd ~
git clone https://github.com/anbox/anbox-modules.git
cd anbox-modules
