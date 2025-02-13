#!/bin/bash
useradd -m -u 1010 -s /bin/bash sshuser
echo "parol dla polzovatela sshuser:"
passwd sshuser
apt update && apt install -y sudo
echo "sshuser ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/sshuser
chmod 440 /etc/sudoers.d/sshuser
su - sshuser -c "sudo apt update"