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
  cluster_name = local.common_vars.project_name
  network = dependency.network.outputs.network_id
  subnet = dependency.network.outputs.private_subnets
  node_tag = local.common_vars.project_name
  
  # Optional: Customize default values for all node groups
  # default_desired_capacity = 3
  # default_min_capacity = 2
  # default_max_capacity = 10
  # default_instance_types = ["t3.medium", "t3.large"]
  # default_capacity_type = "ON_DEMAND"
  
  # Optional: Customize node groups configuration
  # Uncomment and modify the following to customize your node groups
  # node_groups = {
  #   primary = {
  #     desired_capacity = 3
  #     min_capacity     = 2
  #     max_capacity     = 10
  #     instance_type    = "t3.medium"
  #     capacity_type    = "ON_DEMAND"
  #     tags = {
  #       Environment = "production"
  #       Team        = "platform"
  #     }
  #   }
  #   # Example: Add a second node group with different configuration
  #   # spot_workers = {
  #   #   desired_capacity = 2
  #   #   min_capacity     = 0
  #   #   max_capacity     = 5
  #   #   instance_types   = ["t3.large", "t3.xlarge"]
  #   #   capacity_type    = "SPOT"
  #   #   tags = {
  #   #     Environment = "production"
  #   #     WorkloadType = "batch"
  #   #   }
  #   # }
  # }
}
