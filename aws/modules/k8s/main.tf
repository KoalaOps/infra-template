# Create an EKS cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  subnet_ids         =  var.subnet
  vpc_id          = var.network
  cluster_version = "1.28"
  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true
  self_managed_node_groups = var.node_groups
}

