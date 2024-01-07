module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  subnet_ids      =  var.subnet
  vpc_id          = var.network
  cluster_version = "1.28"
  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true
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
}