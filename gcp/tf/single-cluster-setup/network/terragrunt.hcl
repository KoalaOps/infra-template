include {
  path = find_in_parent_folders()
}
locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  effective_image_repo_id = try(local.common_vars.image_repo_id, "${local.common_vars.project_resource_prefix}")
}

terraform {
  source = "../../modules/network-with-nat"
}

inputs = {
  project_id = local.common_vars.project_id
  project_resource_prefix = local.common_vars.project_resource_prefix
  primary_location = local.common_vars.primary_location
  locations = local.common_vars.locations
}