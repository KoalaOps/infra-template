# Description: Production environment

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
}
