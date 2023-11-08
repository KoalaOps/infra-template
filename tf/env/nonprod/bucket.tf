terraform {
  backend "gcs" {
    bucket = "PROJECT_NAME-terraform-backend"
    prefix = "terraform/state-nonprod"
  }
}
