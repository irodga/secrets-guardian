variable "region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "vault_instance_type" {
  description = "EC2 instance type for Vault"
  type        = string
}

variable "vault_ami_id" {
  description = "AMI ID for Vault EC2"
  type        = string
}

variable "allow_destroy" {
  description = "Permitir destrucción de recursos críticos"
  type        = bool
}

variable "tf_backend_bucket" {
  description = "Nombre del bucket para Terraform state"
  type        = string
}

variable "tf_backend_key" {
  description = "Ruta del state file"
  type        = string
}

variable "tf_backend_table" {
  description = "Nombre de la tabla DynamoDB para locking"
  type        = string
}
