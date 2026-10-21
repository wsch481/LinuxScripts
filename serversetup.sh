#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run with root privileges (sudo)." >&2
  exit 1
fi

echo "=========================================="
echo " Starting Post-Install Server Configuration"
echo "=========================================="

# Update system repositories and upgrade system
echo "[*] Updating apt package indices..."
apt update -y && apt upgrade -y

# Install missing foundational network handling binaries
echo "[*] Installing common applications..."
apt install -y curl ca-certificates tree fastfetch ncdu ufw

echo "[*] Adding Fastfetch to all users logins..."
cat << 'EOF' | sudo tee /etc/profile.d/fastfetch.sh > /dev/null
# Run fastfetch on login if it is installed
if command -v fastfetch >/dev/null 2>&1; then
    fastfetch
fi
EOF

sudo chmod +x /etc/profile.d/fastfetch.sh

LINE_TO_ADD="command -v fastfetch >/dev/null 2>&1 && fastfetch"

if ! sudo grep -Fq "fastfetch" /etc/skel/.bashrc; then
    echo -e "\n# Run fastfetch if available\n$LINE_TO_ADD" | sudo tee -a /etc/skel/.bashrc > /dev/null
    echo "Updated skeleton template for future users."
fi

echo "Successfully configured fastfetch globally for all users."

# Fetch and install the latest XCP-ng Guest Utilities
echo "[*] Downloading and unpacking XCP-ng Management Utilities..."
wget https://github.com/xenserver/xe-guest-utilities/releases/download/v10.0.0/xe-guest-utilities_10.0.0-1_amd64.deb -O /tmp/xe-tools.deb

if [ -f /tmp/xe-tools.deb ]; then
  # Use dpkg directly to avoid path evaluation constraints seen in apt
  dpkg -i /tmp/xe-tools.deb || apt install -f -y
  rm -f /tmp/xe-tools.deb
  echo "[+] XCP-ng Utilities installed successfully."
else
  echo "[!] Error: Failed to download the guest tools package archive." >&2
fi

## Change Server  hostname and IP Address
# Gather User Input
echo "=== System Configuration Update ==="
read -p "Enter new Hostname: " NEW_HOSTNAME
read -p "Enter new FQDN (e.g., ://example.com): " NEW_FQDN
read -p "Enter new IP Address: " NEW_IP

# Validate that inputs are not empty
if [ -z "$NEW_HOSTNAME" ] || [ -z "$NEW_FQDN" ] || [ -z "$NEW_IP" ]; then
  echo "Error: All fields are required. Operation canceled."
  exit 1
fi

echo -e "\nApplying updates..."

# Update Hostname
echo "Changing hostname to: $NEW_HOSTNAME"
hostnamectl set-hostname "$NEW_HOSTNAME"

# Update /etc/hosts
# Replaces the default "127.0.0.1 debian" line with the new FQDN and hostname
if grep -q "127.0.1.1	debian" /etc/hosts; then
  echo "Updating /etc/hosts entry..."
  sed -i "s/127.0.1.1	debian/127.0.0.1	$NEW_HOSTNAME.$NEW_FQDN	$NEW_HOSTNAME/g" /etc/hosts
else
  echo "Warning: Default '127.0.1.1	debian' line not found in /etc/hosts."
  echo "Appending new entry to /etc/hosts instead..."
  echo "127.0.0.1	$NEW_HOSTNAME.$NEW_FQDN	$NEW_HOSTNAME" >> /etc/hosts
fi

# Update Static IP Address
# This updates the classic Debian network interfaces configuration file.
TARGET_NET_FILE="/etc/network/interfaces"

# Dynamically find the current primary IP address
OLD_IP=$(hostname -I | awk '{print $1}')

# Ensure we actually found an IP address before proceeding
if [ -z "$OLD_IP" ]; then
  echo "Error: Could not determine the current IP address."
  exit 1
fi

if [ -f "$TARGET_NET_FILE" ]; then
  if grep -q "$OLD_IP" "$TARGET_NET_FILE"; then
    echo "Updating IP address from $OLD_IP to $NEW_IP in $TARGET_NET_FILE..."
    sed -i "s/$OLD_IP/$NEW_IP/g" "$TARGET_NET_FILE"
  else
    echo "Warning: Current IP address ($OLD_IP) was not found in $TARGET_NET_FILE."
  fi
else
  echo "Warning: $TARGET_NET_FILE not found. If you use NetworkManager, you may need to update your IP via nmcli."
fi

# Interactive Password Updates
echo -e "\n=== Password Updates ==="

# Change the password for the root user
echo "Changing password for 'root'..."
passwd root

# Change the password for the original user who ran the sudo command
if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
  echo "Changing password for logged-in user '$SUDO_USER'..."
  passwd "$SUDO_USER"
else
  echo "No distinct non-root logged-in user detected via SUDO_USER."
fi


echo -e "\n=== Configuration Complete ==="
echo "Please reboot your system or restart network services to apply all changes completely."
