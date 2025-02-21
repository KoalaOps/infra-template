include {
  path = find_in_parent_folders()
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

# Exclude ArgoCD IAM setup if not enabled
exclude {
  if = !local.common_vars.enable_argocd
  actions = ["plan", "apply", "destroy", "init", "validate", "refresh"]  # Exclude all actions except output access
  exclude_dependencies = false  # Keep dependencies available for other modules that might need them
}

terraform {
  source = "../../modules/argocd-iam"
}

dependency "management" {
  config_path = "../eks-management"
}

dependency "prod" {
  config_path = "../eks-prod"
}

dependency "nonprod" {
  config_path = "../eks-nonprod"
}

inputs = {
  project_name = local.common_vars.project_name
  management_cluster_name = dependency.management.outputs.name
  managed_cluster_names = [
    dependency.prod.outputs.name,
    dependency.nonprod.outputs.name
  ]
}