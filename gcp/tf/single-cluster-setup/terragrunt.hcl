# Indicate the input values to use for the variables of the module.
locals {
    common_vars = yamldecode(file("./common_vars.yaml"))
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
    bucket                = "${local.common_vars.project_name}-tf-state"
    prefix                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}

inputs = {
  location = local.common_vars.primary_location
}

# creates environment variables so that modules with matching variable names can automatically read these values
terraform {
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()

    env_vars = {
        TF_VAR_project_id = local.common_vars.project_id
    }
  }
}