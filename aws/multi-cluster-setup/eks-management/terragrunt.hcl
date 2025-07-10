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
  cluster_name = "${local.common_vars.project_name}-${local.common_vars.region}-mng"
  network = dependency.network.outputs.network_id
  subnet = dependency.network.outputs.private_subnets
  node_tag = local.common_vars.project_name
  
  # Management cluster configuration - optimized for management tools like ArgoCD
  default_desired_capacity = 2
  default_min_capacity = 2
  default_max_capacity = 6
  default_instance_types = ["t3.medium"]
  
  # Optional: Customize node groups for management workloads
  # node_groups = {
  #   management = {
  #     desired_capacity = 2
  #     min_capacity     = 2
  #     max_capacity     = 6
  #     instance_type    = "t3.medium"
  #     capacity_type    = "ON_DEMAND"  # Use ON_DEMAND for management services
  #     tags = {
  #       Environment = "management"
  #       Purpose     = "control-plane"
  #     }
  #   }
  # }
}
