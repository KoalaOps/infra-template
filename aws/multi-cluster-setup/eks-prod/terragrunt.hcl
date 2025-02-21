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

dependency "management" {
  config_path = "../eks-management"
}

inputs = {
  cluster_name = "${local.common_vars.region}-prod"
  network = dependency.network.outputs.network_id
  subnet = dependency.network.outputs.private_subnets
  node_tag = local.common_vars.project_name
  management_cluster_sg_id = dependency.management.outputs.node_security_group_id
}
