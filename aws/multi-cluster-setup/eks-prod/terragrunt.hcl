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
  
  # Production cluster configuration - higher capacity and availability
  default_desired_capacity = 3
  default_min_capacity = 2
  default_max_capacity = 20
  default_instance_types = ["t3.large"]
  
  # Optional: Production-ready node groups configuration
  # node_groups = {
  #   primary = {
  #     desired_capacity = 3
  #     min_capacity     = 2
  #     max_capacity     = 20
  #     instance_types   = ["t3.large", "t3.xlarge"]
  #     capacity_type    = "ON_DEMAND"
  #     tags = {
  #       Environment = "production"
  #       Criticality = "high"
  #     }
  #   }
  #   # Example: Add a spot node group for non-critical workloads
  #   # spot_workers = {
  #   #   desired_capacity = 2
  #   #   min_capacity     = 0
  #   #   max_capacity     = 10
  #   #   instance_types   = ["t3.large", "t3.xlarge", "m5.large"]
  #   #   capacity_type    = "SPOT"
  #   #   tags = {
  #   #     Environment = "production"
  #   #     WorkloadType = "batch-processing"
  #   #   }
  #   # }
  # }
}
