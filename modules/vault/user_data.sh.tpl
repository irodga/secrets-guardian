#!/bin/bash
echo "Inicializando Vault..." > /var/log/vault-init.log

# Setear VAULT_ADDR y AWS_REGION como globales
export VAULT_ADDR=http://127.0.0.1:8200
export AWS_REGION=${region}
echo "export VAULT_ADDR=http://127.0.0.1:8200" >> /etc/profile
echo "export AWS_REGION=${region}" >> /etc/profile

# Paquetes base
yum install -y nfs-utils amazon-ssm-agent unzip wget jq awscli >> /var/log/vault-init.log 2>&1
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Crear punto de montaje
mkdir -p /mnt/vault

# Montar FSx con retry
echo "[INFO] Intentando montar FSx..." >> /var/log/vault-init.log
for i in {1..5}; do
  mount -t nfs4 -o nfsvers=4.1 ${fsx_dns}:/fsx /mnt/vault >> /var/log/vault-init.log 2>&1
  if [ $? -eq 0 ]; then
    echo "[SUCCESS] FSx montado correctamente" >> /var/log/vault-init.log
    break
  else
    echo "[WARN] Fallo al montar FSx. Reintento $i/5 en 10 segundos..." >> /var/log/vault-init.log
    sleep 10
  fi
done

df -h >> /var/log/vault-init.log

# Instalar Vault
wget https://releases.hashicorp.com/vault/1.15.5/vault_1.15.5_linux_amd64.zip >> /var/log/vault-init.log 2>&1
unzip vault_1.15.5_linux_amd64.zip >> /var/log/vault-init.log 2>&1
mv vault /usr/local/bin/
useradd --system --home /etc/vault.d --shell /bin/false vault

mkdir -p /etc/vault.d /mnt/vault/data
chown -R vault:vault /mnt/vault/data
chmod 700 /mnt/vault/data

# Config de Vault
cat <<EOT > /etc/vault.d/vault.hcl
storage "file" {
  path = "/mnt/vault/data"
}

seal "awskms" {
  region     = "${region}"
  kms_key_id = "${kms_key_id}"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

disable_mlock = true
ui = true
EOT

chown vault:vault /etc/vault.d/vault.hcl

# Servicio systemd
cat <<EOT > /etc/systemd/system/vault.service
[Unit]
Description=Vault
After=network.target

[Service]
User=vault
Group=vault
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP \$MAINPID
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reexec
systemctl enable vault
systemctl start vault

# Script auto-unseal
cat <<'EOS' > /usr/local/bin/vault-auto-unseal.sh
#!/bin/bash
export VAULT_ADDR=http://127.0.0.1:8200
export AWS_REGION=${region}

SECRET=$(aws secretsmanager get-secret-value \
  --secret-id guardian-vault-init \
  --query SecretString \
  --output text)

UNSEAL_KEYS=$(echo "$SECRET" | jq -r '.unseal_keys_b64[]')

COUNT=0
for KEY in $UNSEAL_KEYS; do
  vault operator unseal "$KEY"
  COUNT=$((COUNT + 1))
  if [ $COUNT -eq 3 ]; then
    break
  fi
done
EOS

chmod +x /usr/local/bin/vault-auto-unseal.sh

# Script root token
cat <<'EOS' > /usr/local/bin/vault-root-token.sh
#!/bin/bash
export AWS_REGION=${region}

SECRET=$(aws secretsmanager get-secret-value \
  --secret-id guardian-vault-init \
  --query SecretString \
  --output text)

echo "$SECRET" | jq -r '.root_token'
EOS

chmod +x /usr/local/bin/vault-root-token.sh

# Ejecutar auto-unseal al arranque
echo "/usr/local/bin/vault-auto-unseal.sh" >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local
