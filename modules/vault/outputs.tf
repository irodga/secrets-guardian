output "vault_instance_id" {
  description = "ID de la instancia EC2 de Vault"
  value       = aws_instance.vault.id
}

output "vault_private_ip" {
  description = "IP privada de la instancia de Vault"
  value       = aws_instance.vault.private_ip
}

output "vault_public_dns" {
  description = "DNS público de la instancia de Vault (si tiene IP pública)"
  value       = aws_instance.vault.public_dns
}

output "vault_sg_id" {
  description = "ID del Security Group asignado a Vault"
  value       = aws_security_group.vault_sg.id
}

output "vault_instance_profile_name" {
  description = "Nombre del Instance Profile usado por la instancia de Vault"
  value       = aws_iam_instance_profile.vault_profile.name
}
