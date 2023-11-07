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
#module "redis" {
#  source                  = "../../modules/redis"
#  project_id              = var.project_id
#  region                  = var.region
#  tier                    = var.redis_tier
#  memory_size_gb          = var.redis_memory_size
#  redis_version           = var.redis_version
#  authorized_network_name = data.terraform_remote_state.management.outputs.network_name
#}


# # Get credentials for cluster
# module "gcloud" {
#   source  = "terraform-google-modules/gcloud/google"
#   version = "~> 3.0"

#   platform              = "linux"
#   additional_components = ["kubectl", "beta"]

#   create_cmd_entrypoint = "gcloud"
#   # Use local variable cluster_name for an implicit dependency on resource "google_container_cluster" 
#   create_cmd_body = "container clusters get-credentials ${var.cluster_name} --zone=${var.location}"
# }

# # Apply YAML files for cluster level configurations (ArgoCD, Argo Rollout, ingress-nginx, namespaces, etc)
# resource "null_resource" "apply_cluster_manifests" {
#   triggers = {
#     always_run = "${timestamp()}"
#   }

#   provisioner "local-exec" {
#     interpreter = ["bash", "-exc"]
#     command     = "/bin/bash ../../../k8s-manifests/setup_cluster.sh"
#   }

#   depends_on = [
#     module.gcloud
#   ]
# }
