include {
  path = find_in_parent_folders()
}
locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

terraform {
  source = "../../modules/image-registry"
}

inputs = {
  image_repo_id = local.common_vars.project_name
}