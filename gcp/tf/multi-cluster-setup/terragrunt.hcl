# Indicate the input values to use for the variables of the module.
locals {
    common_vars = yamldecode(file("./common_vars.yaml"))
    # Validate project_resource_prefix ends with letter or digit
    prefix_validation = regex("^.*[A-Za-z0-9]$", local.common_vars.project_resource_prefix) != null ? null : file("ERROR: project_resource_prefix must end with a letter or number")
    effective_state_name = try(local.common_vars.tf_state_bucket, "${local.common_vars.project_resource_prefix}-tf-state")
}

generate "common_vars" {
  path      = "common_vars.tf"
  if_exists = "overwrite"
  # the following variables will be pushed to all modules
  contents  = <<EOF
variable "project_id" {
  description = "project id"
}

provider "google" {
  project = var.project_id
}
EOF
}

# docs https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#remote_state
remote_state {
  backend  = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    project               = local.common_vars.project_id
    location              = local.common_vars.primary_location
    bucket                = local.effective_state_name
    prefix                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}

inputs = {
  location = local.common_vars.primary_location
}

# Creates environment variables so that modules with matching variable names can automatically read these values
terraform {
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()

    env_vars = {
        TF_VAR_project_id = local.common_vars.project_id
    }
  }
}

# Global dependencies configuration
dependencies {
  paths = get_terragrunt_dir() != "${get_parent_terragrunt_dir()}/project-services" ? ["./project-services"] : []
}

dependency "project-services" {
  config_path = "./project-services"
  skip_outputs = true
  
  mock_outputs = {
    enabled_apis = []
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  
  # Don't create dependency for project-services itself
  enabled = get_terragrunt_dir() != "${get_parent_terragrunt_dir()}/project-services"
}