output "vault_instance_id" {
  value = aws_instance.vault.id
}

output "vault_sg_id" {
  value = aws_security_group.vault_sg.id
}
