# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket         = "eyal-startup-tf-state"
    dynamodb_table = "terraform_table"
    encrypt        = false
    key            = "./terraform.tfstate"
    profile        = "AdministratorAccess-182885424439"
    region         = "us-east-1"
  }
}
