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
  cluster_name = "${local.common_vars.region}-nonprod"
  network = dependency.network.outputs.network_id
  subnet = dependency.network.outputs.private_subnets
  node_tag = local.common_vars.project_name
  management_cluster_sg_id = dependency.management.outputs.node_security_group_id
  
  # Non-production cluster configuration - cost-optimized
  default_desired_capacity = 2
  default_min_capacity = 2  # Minimum 2 nodes for testing multiple services
  default_max_capacity = 10
  default_instance_types = ["t3.medium"]
  default_capacity_type = "SPOT"  # Use SPOT instances for cost savings
  
  # Optional: Non-production node groups configuration
  # node_groups = {
  #   primary = {
  #     desired_capacity = 2
  #     min_capacity     = 2  # Minimum 2 nodes for testing multiple services
  #     max_capacity     = 10
  #     instance_types   = ["t3.medium", "t3.large"]
  #     capacity_type    = "SPOT"  # Cost-effective for testing
  #     tags = {
  #       Environment = "nonprod"
  #       CostCenter  = "development"
  #     }
  #   }
  #   # Example: Add on-demand node group for critical testing workloads
  #   # on_demand = {
  #   #   desired_capacity = 1
  #   #   min_capacity     = 0
  #   #   max_capacity     = 3
  #   #   instance_type    = "t3.medium"
  #   #   capacity_type    = "ON_DEMAND"
  #   #   tags = {
  #   #     Environment = "nonprod"
  #   #     WorkloadType = "stable-testing"
  #   #   }
  #   # }
  # }
}
