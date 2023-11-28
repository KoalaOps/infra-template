# Indicate the input values to use for the variables of the module.
locals {
    common_vars = yamldecode(file("./common_vars.yaml"))
}

generate "common_vars" {
  path      = "common_vars.tf"
  if_exists = "overwrite"
  contents  = <<EOF
variable "region" {
    description = "region name"
}
variable "profile" {
    description = "profile name"
}
provider "aws" {
  region = var.region
  profile = var.profile
}
EOF
}
remote_state {
  backend  = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket                = local.common_vars.tf_state_bucket != null ? local.common_vars.tf_state_bucket : local.common_vars.project_name + "-tf-state"
    disable_bucket_update = true
    key                   = "${path_relative_to_include()}/terraform.tfstate"
    region                = local.common_vars.region
    profile               = local.common_vars.profile
    encrypt               = false
#    encrypt               = true
#    kms_key_id            = local.common_vars.state_kms_key_id  - aws kms create
    dynamodb_table        = "terraform_table"
  }
}

inputs = {
    region = local.common_vars.region
    profile = local.common_vars.profile
}