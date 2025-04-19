variable "vault_ami_id" {
  type        = string
  description = "AMI ID para la instancia de Vault"
}

variable "vault_instance_type" {
  type        = string
  description = "Tipo de instancia EC2 para Vault"
}

variable "vault_bucket" {
  type        = string
  description = "Nombre del bucket S3 usado por Vault si aplica"
}

variable "kms_key_arn" {
  type        = string
  description = "ARN de la llave KMS para auto-unseal"
}

variable "kms_key_id" {
  type        = string
  description = "ID de la llave KMS para auto-unseal (no ARN)"
}

variable "fsx_dns" {
  type        = string
  description = "DNS de FSx para montar como storage"
}

variable "subnet_id" {
  type        = string
  description = "ID de la subred privada donde se lanza Vault"
}

variable "vpc_id" {
  type        = string
  description = "ID de la VPC donde se crea el SG"
}

variable "key_name" {
  type        = string
  description = "Nombre de la key pair SSH (opcional si solo usas SSM)"
}

variable "region" {
  type        = string
  description = "Región AWS (para el seal de KMS)"
}

variable "cluster_name" {
  type        = string
  description = "Nombre del cluster base para nombrar recursos"
}
