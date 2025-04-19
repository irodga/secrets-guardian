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

module "fsx" {
  source             = "./modules/fsx"
  private_subnet_id  = module.vpc.private_subnets[0]
  security_group_ids = [module.vpc.fsx_security_group_id]
}

module "vault" {
  source               = "./modules/vault"
  vault_ami_id         = var.vault_ami_id
  vault_instance_type  = var.vault_instance_type
  vault_bucket         = module.bootstrap.vault_bucket_name
  kms_key_arn          = module.kms.kms_key_arn
  fsx_dns              = module.fsx.fsx_dns_name
  subnet_id            = module.vpc.private_subnets[0]
  vpc_id               = module.vpc.vpc_id
}
