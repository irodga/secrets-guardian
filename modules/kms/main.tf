resource "aws_kms_key" "vault_key" {
  description         = "KMS key for Vault and storage encryption"
  enable_key_rotation = true
  tags = {
    Name = "guardian-vault-kms"
  }
}

resource "aws_kms_alias" "vault_key_alias" {
  name          = "alias/guardian-vault-kms"
  target_key_id = aws_kms_key.vault_key.key_id
}
