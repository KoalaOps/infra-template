include {
  path = find_in_parent_folders()
}
locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  effective_cluster_name = try(local.common_vars.prod_cluster_name, "${local.common_vars.project_resource_prefix}-prod")
}

terraform {
  source = "../../modules/k8s-private-nodes-cluster"
}
dependency "network" {
    config_path = "../network"
}
dependencies {
  paths = ["../image-repo" , "../project-services"]
}
inputs = {
  project_id = local.common_vars.project_id
  project_resource_prefix = local.common_vars.project_resource_prefix
  location = local.common_vars.primary_location
  name = local.effective_cluster_name
  network = dependency.network.outputs.network_name
  subnet = dependency.network.outputs.subnet_names[local.common_vars.primary_location]
  min_node_count = 1
  max_node_count = 3
  machine_type = "e2-standard-2"
  enable_autopilot = try(local.common_vars.enable_autopilot, true)
}