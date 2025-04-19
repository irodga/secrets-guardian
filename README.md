🔐 Secrets Guardian - Vault Deployment (Fase 1 y 2)

Este repositorio implementa una arquitectura completa de Vault sobre AWS, asegurando alta disponibilidad, persistencia de datos y seguridad automatizada. A continuación, se documentan todos los pasos, infraestructura y comandos utilizados para desplegar, configurar e inicializar Vault correctamente.

📦 Infraestructura Provisionada

Todo esto se creó con Terraform modular desde la carpeta raíz:

VPC con subredes públicas y privadas

EC2 para Vault con user_data.sh.tpl

Amazon FSx for OpenZFS para almacenamiento persistente

KMS Key para auto-unseal

S3 + DynamoDB como backend remoto (opcional)

Secrets Manager para almacenar claves y root token

⚙️ Instancia EC2 de Vault

Instalación automatizada (user_data.sh.tpl):

Instala Vault

Monta FSx en /mnt/vault

Configura vault.hcl

Habilita auto-unseal vía KMS

Crea servicio systemd de Vault

Incluye scripts:

/usr/local/bin/vault-auto-unseal.sh

/usr/local/bin/vault-root-token.sh

🔐 Inicialización Manual de Vault (Fase 2)

1. Conectarse a la instancia:

aws ssm start-session --target <instance-id>

2. Entrar como root:

sudo su -

3. Exportar VAULT_ADDR:

export VAULT_ADDR=http://127.0.0.1:8200

4. Inicializar Vault (modo KMS - no usar key-shares):

vault operator init -format=json > /root/vault-init.json

5. Verificar archivo:

cat /root/vault-init.json | jq .

6. Guardar en Secrets Manager:

aws secretsmanager create-secret \
  --name guardian-vault-init \
  --description "Vault root token y recovery keys" \
  --secret-string file:///root/vault-init.json \
  --region us-east-1

7. (Opcional) Eliminar el archivo local:

rm /root/vault-init.json

🔁 Validación de recuperación automática

Para simular reinicio:

terraform destroy -target=module.vault.aws_instance.vault
terraform apply

Verificar estado en la nueva instancia:

vault status

Deberías ver:

Initialized: true

Sealed: false

Recuperar root token:

/usr/local/bin/vault-root-token.sh

📌 Próximo objetivo: Fase 3

Habilitar TLS + dominio personalizado

Crear policy app-admin

Generar token con TTL renovable

Configurar backend externo para consumir Vault vía HTTPS

📂 Estructura del repositorio (simplificada)

.
├── main.tf
├── terraform.tfvars
├── modules/
│   ├── vault/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── user_data.sh.tpl
│   ├── fsx/
│   ├── kms/
│   └── vpc/
└── policies/
    └── app-admin.hcl

🧠 Notas finales

El secreto guardian-vault-init en Secrets Manager es esencial para que el auto-unseal funcione.

El FSx mantiene persistencia incluso si destruyes la EC2.

Nunca vuelvas a correr vault operator init si Vault ya está inicializado.

Toda la infraestructura es recreable automáticamente, excepto el init, que se hace una sola vez por seguridad.