resource "aws_fsx_openzfs_file_system" "vault_fsx" {
  storage_capacity    = 1200
  deployment_type     = "SINGLE_AZ_1"
  throughput_capacity = 128
  subnet_ids          = [var.private_subnet_id]
  security_group_ids  = var.security_group_ids

  root_volume_configuration {
    copy_tags_to_snapshots = true

    nfs_exports {
      client_configurations {
        clients = "10.0.0.0/16"
        options = ["rw", "sync", "no_root_squash"]
      }
    }
  }

  tags = {
    Name = "guardian-fsx-vault"
  }
}
