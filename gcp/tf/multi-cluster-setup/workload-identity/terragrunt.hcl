include {
  path = find_in_parent_folders()
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

terraform {
  source = "../../modules/workload-identity-federation"
}

dependencies {
  paths = ["../project-services"]
}

inputs = {
  project_id = local.common_vars.project_id
  github_org = local.common_vars.github_org
  region = "global"
  
  # Use existing variables from common_vars.yaml
  artifact_registry_location = local.common_vars.primary_location
  artifact_registry_repository_name = "${local.common_vars.project_resource_prefix}-repo"
} 