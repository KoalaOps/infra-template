module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  cluster_name                    = var.cluster_name
  subnet_ids                      = var.subnet
  vpc_id                          = var.network
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # Configure Pod Identity (IAM roles for service accounts). Keep the older ConfigMap approach available for backwards compatibility.
  authentication_mode = "API_AND_CONFIG_MAP"

  # Enable cluster creator admin permissions. Disable this if you want to use a different role as cluster admin.
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.medium"]

      desired_capacity = 2
      max_capacity     = 50
      min_capacity     = 1
    }
  }

  # Add security group rules for management cluster access
  node_security_group_additional_rules = var.allow_management_cluster_access && var.management_cluster_sg_id != "" ? {
    ingress_from_management = {
      description              = "Allow access from management cluster nodes"
      protocol                 = "-1"
      from_port                = 0
      to_port                  = 0
      type                     = "ingress"
      source_security_group_id = var.management_cluster_sg_id
    }
  } : {}

  # Add rules to allow management cluster to access the K8s API server
  cluster_security_group_additional_rules = var.allow_management_cluster_access && var.management_cluster_sg_id != "" ? {
    ingress_from_management_cluster = {
      description              = "Allow management cluster to access API server"
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      type                     = "ingress"
      source_security_group_id = var.management_cluster_sg_id
    }
  } : {}
}
