#!/bin/bash

read -p "How many nodes do you want to generate? " COUNT
read -p "Enter starting IP suffix (e.g., 10 for 10.0.0.10): " START_IP

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
filter = { ID_NET_NAME = "ens18" }

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
