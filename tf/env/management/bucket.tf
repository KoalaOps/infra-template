terraform {
  backend "gcs" {
    bucket = "koalaops-terraform-backend"
    prefix = "terraform/state-management"
  }
}