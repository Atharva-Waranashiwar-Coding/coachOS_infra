locals { name = "${var.project}-${var.environment}" }

module "network" {
  source             = "../../modules/network"
  name               = local.name
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}

module "iam" {
  source = "../../modules/iam"
  name   = local.name
}

module "compute" {
  source                = "../../modules/compute"
  name                  = local.name
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  subnet_id             = module.network.public_subnet_ids[0]
  vpc_id                = module.network.vpc_id
  instance_profile_name = module.iam.instance_profile_name
  ssh_key_name          = var.ssh_key_name
  allowed_ssh_cidrs     = var.allowed_ssh_cidrs
  root_volume_gib       = var.root_volume_gib
  user_data             = file(var.cloud_init_path)
}

module "object_storage" {
  source = "../../modules/object-storage"
  name   = local.name
}
module "storage" {
  source = "../../modules/storage"
  name   = local.name
}
module "monitoring" {
  source = "../../modules/monitoring"
  name   = local.name
}
