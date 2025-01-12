include {
  path = find_in_parent_folders()
}
locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  effective_image_repo_id = try(local.common_vars.image_repo_id, "${local.common_vars.project_resource_prefix}")
}

terraform {
  source = "../../modules/image-registry"
}

inputs = {
  project_id = local.common_vars.project_id
  image_repo_id = local.effective_image_repo_id
}
