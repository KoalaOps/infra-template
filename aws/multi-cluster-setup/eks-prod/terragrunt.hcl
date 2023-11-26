include {
  path = find_in_parent_folders()
}
locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

terraform {
  source = "../../modules/k8s"
}

dependency "network" {
    config_path = "../network"
}
dependencies {
  paths = ["../image-repo"]
}

inputs = {
  cluster_name = format("%s-%s-prod",  local.common_vars.cluster_name , local.common_vars.region)
  network = dependency.network.outputs.network_id
  subnet = dependency.network.outputs.private_subnets
  node_tag =  local.common_vars.project_name
}
