resource "aws_s3_bucket" "vault_storage" {
  bucket = var.vault_bucket

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm      = "aws:kms"
        kms_master_key_id  = var.kms_key_arn
      }
    }
  }

  tags = {
    Name = "Vault Storage Bucket"
  }
}

resource "aws_s3_bucket" "tf_state" {
  bucket = var.tf_backend_bucket

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm      = "aws:kms"
        kms_master_key_id  = var.kms_key_arn
      }
    }
  }

  tags = {
    Name = "Terraform State Bucket"
  }
}

resource "aws_dynamodb_table" "tf_locks" {
  name         = var.tf_backend_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled      = true
    kms_key_arn  = var.kms_key_arn
  }

  tags = {
    Name = "Terraform Lock Table"
  }
}
