# Description: Management environment

locals {
    // Use the ternary operator to check if image_repo_id is set. If not, use project_name with '-repo' suffix.
  effective_image_repo_id  = var.image_repo_id != null ? var.image_repo_id : "${var.project_name}-repo"
}

module "project_services" {
  source      = "../../modules/project-services"
  project_id  = var.project_id
  enable_apis = true
}

module "image_registry" {
  source        = "../../modules/image-registry"
  project_id    = var.project_id
  location      = var.region
  image_repo_id = local.effective_image_repo_id
}

module "network" {
  source     = "../../modules/network"
  project_id = var.project_id
  regions    = var.regions
}

# module "k8s_cluster" {
#   source        = "../../modules/k8s-cluster"
#   project_id    = var.project_id
#   location      = var.location
#   name          = var.cluster_name
#   node_count    = var.node_count
#   machine_type  = var.machine_type
#   network       = module.network.network_name
#   subnet        = module.network.subnet_names[var.region]
# }
