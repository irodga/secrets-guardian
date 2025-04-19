output "fsx_dns_name" {
  description = "DNS para montar vía NFS"
  value       = aws_fsx_openzfs_file_system.vault_fsx.dns_name
}

output "fsx_mount_name" {
  description = "Nombre del punto de montaje NFS"
  value = tolist(flatten([
    for cfg in aws_fsx_openzfs_file_system.vault_fsx.root_volume_configuration[0].nfs_exports[0].client_configurations :
    cfg.clients
  ]))[0]
}

output "fsx_id" {
  description = "ID del FSx for OpenZFS"
  value       = aws_fsx_openzfs_file_system.vault_fsx.id
}
