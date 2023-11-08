# Description: Non-Production Environment
# Reference the prod state for resources created there that are used also in nonprod.
data "terraform_remote_state" "management" {
  backend = "gcs"
  config = {
    bucket = "PROJECT_NAME-terraform-backend"
    prefix = "terraform/state-management"
  }
}

module "k8s_cluster" {
  source        = "../../modules/k8s-cluster"
  project_id    = var.project_id
  location      = var.location
  image_repo_id = var.image_repo_id
  name          = format("%s-%s", var.cluster_name, var.region)
  node_count    = var.node_count
  machine_type  = var.machine_type
  network       = data.terraform_remote_state.management.outputs.network_name
  subnet        = data.terraform_remote_state.management.outputs.subnet_names[var.region]

  install-cert-manager             = true
  install-nginx-ingress            = true
  install-secrets-store-csi-driver = true
}

# Example for adding a Redis instance to the nonprod environment. Uncomment to use (as well as the variables in variables.tf and terraform.tfvars).
# module "redis" {
#   source                  = "../../modules/redis"
#   project_id              = var.project_id
#   region                  = var.region
#   tier                    = var.redis_tier
#   memory_size_gb          = var.redis_memory_size
#   redis_version           = var.redis_version
#   authorized_network_name = data.terraform_remote_state.management.outputs.network_name
# }
