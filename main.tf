module "kms" {
  source = "./modules/kms"
}

module "bootstrap" {
  source              = "./modules/bootstrap"
  tf_backend_bucket   = var.tf_backend_bucket
  tf_backend_table    = var.tf_backend_table
  vault_bucket        = "guardian-vault-storage"
  kms_key_arn         = module.kms.kms_key_arn
}

module "vpc" {
  source = "./modules/vpc"
  region = var.region
}
