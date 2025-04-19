output "kms_key_arn" {
  description = "ARN de la llave KMS usada para auto-unseal de Vault"
  value       = aws_kms_key.vault_key.arn
}

output "kms_key_id" {
  description = "ID de la llave KMS (usado por Vault para auto-unseal)"
  value       = aws_kms_key.vault_key.key_id
}
