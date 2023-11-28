include {
  path = find_in_parent_folders()
}
locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}
terraform {
  source = "../../modules/network"
}

inputs = {
  name = local.common_vars.project_name
  vpc_cidr = "10.0.0.0/16"
}

