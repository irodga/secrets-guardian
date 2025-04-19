output "kms_key_arn" {
  value = module.kms.kms_key_arn
}
output "vault_instance_id" {
  value = module.vault.vault_instance_id
}

output "fsx_dns_name" {
  description = "DNS del FSx Lustre"
  value       = module.fsx.fsx_dns_name
}

output "fsx_mount_name" {
  description = "Mount name del FSx Lustre"
  value       = module.fsx.fsx_mount_name
}

output "fsx_id" {
  description = "ID del FSx Lustre"
  value       = module.fsx.fsx_id
}
