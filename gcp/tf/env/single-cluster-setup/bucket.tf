terraform {
  backend "gcs" {
    bucket = "nadav-test-405022-terraform-backend"
    prefix = "terraform/state"
  }
}
