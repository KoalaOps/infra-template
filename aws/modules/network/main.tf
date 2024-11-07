
#locals {
#  subnets = cidrsubnets(var.cidr_block, 8,8,8,8,8,8,8,8)
  #Notice that in AWS every pod in the cluster (aws vpc cni) ypu rather increase the range or use clillum

#  public_subnets  = slice(local.subnets, 0, 3)
#  private_subnets = slice(local.subnets, 4, 7)
#}
data "aws_availability_zones" "available" {
  state = "available"
}
locals {
    azs  = slice(data.aws_availability_zones.available.names, 0, 3)
}

module vpc{
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.15.0"

  name = var.name
  cidr = var.vpc_cidr

  azs  = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 52)]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_ipv6            = true
  create_egress_only_igw = true

  public_subnet_ipv6_prefixes                    = [0, 1, 2]
  public_subnet_assign_ipv6_address_on_creation  = true
  private_subnet_ipv6_prefixes                   = [3, 4, 5]
  private_subnet_assign_ipv6_address_on_creation = true
  intra_subnet_ipv6_prefixes                     = [6, 7, 8]
  intra_subnet_assign_ipv6_address_on_creation   = true

  #where to put leg of the elb
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}