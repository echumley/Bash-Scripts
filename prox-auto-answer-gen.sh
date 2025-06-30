#!/bin/bash

# 1. Architecture check
ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" && "$ARCH" != "amd64" ]]; then
    echo -e "ERROR: This script only supports x86/x64 systems.\nDetected architecture: $ARCH - Exiting..."
    exit 1
fi

# 2. Debian check
if ! grep -qi "debian" /etc/os-release; then
    echo "ERROR: This script must be run on a Debian-based system. Exiting..."
    exit 1
fi

# 3. Debian 12 (Bookworm) check
if ! grep -q "VERSION_CODENAME=bookworm" /etc/os-release; then
    echo "ERROR: This script only supports Debian 12 (Bookworm). Exiting..."
    echo "Detected version:"
    grep VERSION_CODENAME /etc/os-release
    exit 1
fi

# 4. Add Proxmox VE no-subscription repository
echo "Adding Proxmox VE repository..."
echo "deb [arch=amd64] http://download.proxmox.com/debian/pve bookworm pve-no-subscription" | sudo tee /etc/apt/sources.list.d/pve-install-repo.list

# 5. Update & install
echo "Updating package list..."
sudo apt update

echo "Installing proxmox-auto-install-assistant..."
sudo apt install -y proxmox-auto-install-assistant

# 6. Show version
echo "Installed version:"
proxmox-auto-install-assistant --version

# 7. Generate answer files
read -p "How many nodes do you want to generate? " COUNT
read -p "Enter starting IP suffix (e.g., 10 for 10.0.0.10): " START_IP
read -p "Enter network interface (e.g., en0, es18, etc.): " INTERFACE

for ((i = 1; i <= COUNT; i++)); do
    IP_SUFFIX=$((START_IP + i - 1))
    NODE_NAME="node-${i}"
    IP="10.0.0.${IP_SUFFIX}"

    # Generate TOML file - ADJUST AS NEEDED
    cat <<EOF > ${NODE_NAME}.toml
[global]
keyboard = "en-us"
country = "us"
fqdn = "${NODE_NAME}.yourdomain.org"
mailto = "email@email.com"
timezone = "YOURTIMEZONE"
root-password-hashed = "PASSWORDHASH" 
root-ssh-keys = [
  "ssh-ed25519 SSHKEYHASH"
]

[network]
source = "from-answer"
cidr = "${IP}/24"
gateway = "10.0.0.1"
dns = "1.1.1.1"
filter = { ID_NET_NAME = "${INTERFACE}" }

[disk-setup]
filesystem = "zfs"
zfs.raid = "raid1"
disk-list = ["/dev/sda", "/dev/sdb"]
EOF

    # Generate ISO
    proxmox-auto-install-assistant prepare-iso proxmox-ve_8.4-1.iso \
        --fetch-from iso \
        --answer-file ${NODE_NAME}.toml \
        --output ${NODE_NAME}.iso

    echo "Created ${NODE_NAME}.iso with IP ${IP}"
done
