terraform {
  backend "gcs" {
    bucket = "PROJECT_ID-terraform-backend"
    prefix = "terraform/state-nonprod"
  }
}
