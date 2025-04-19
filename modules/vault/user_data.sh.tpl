#!/bin/bash
echo "Inicializando Vault..." > /var/log/vault-init.log

# Instalar cliente NFS y agente SSM en Amazon Linux
yum install -y nfs-utils amazon-ssm-agent >> /var/log/vault-init.log 2>&1

# Arrancar y habilitar SSM
systemctl enable amazon-ssm-agent >> /var/log/vault-init.log 2>&1
systemctl start amazon-ssm-agent >> /var/log/vault-init.log 2>&1

# Montaje de FSx for OpenZFS
mkdir -p /mnt/vault
mount -t nfs4 -o nfsvers=4.1 ${fsx_dns}:/fsx /mnt/vault >> /var/log/vault-init.log 2>&1

# Logs
df -h >> /var/log/vault-init.log
ls -l /mnt/vault >> /var/log/vault-init.log
