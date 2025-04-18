#!/bin/bash
apt update && apt install -y openssh-server
sudo useradd -m -u 1010 -s /bin/bash sshuser
echo "parol dla polzovatela sshuser:"
sudo passwd sshuser
apt update && apt install -y sudo
echo "sshuser ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/sshuser
sudo chmod 440 /etc/sudoers.d/sshuser
sudo su - sshuser -c "sudo apt update"
SSH_DIR="/home/sshuser/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
touch "$AUTHORIZED_KEYS"
chmod 600 "$AUTHORIZED_KEYS"
chown -R sshuser:sshuser "$SSH_DIR"
SSHD_CONFIG="/etc/ssh/sshd_config"
ISSUE_NET="/etc/issue.net"
echo "Port 2024" | tee -a "$SSHD_CONFIG"
echo "AllowUsers sshuser" | tee -a "$SSHD_CONFIG"
echo "Authorized access only" | tee "$ISSUE_NET"
echo "Banner $ISSUE_NET" | tee -a "$SSHD_CONFIG"
sudo systemctl restart sshd
