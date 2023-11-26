locals {
  base_apis = [
    "container.googleapis.com",
    "monitoring.googleapis.com",
    "cloudtrace.googleapis.com",
    "cloudprofiler.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "secretmanager.googleapis.com"
    # "redis.googleapis.com", # Uncomment this line to enable Google Cloud Memorystore for Redis API
  ]
}


# Enable Google Cloud APIs
module "project_services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.0"

  project_id                  = var.project_id
  enable_apis                 = var.enable_apis
  disable_services_on_destroy = false

  activate_apis = local.base_apis
}

# Separate resources are used for some services, to allow the main module to wait specifically for them to be enabled
resource "google_project_service" "artifactregistry" {
  project            = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false

  # Use count to make this resource conditional
  count = var.enable_apis ? 1 : 0
}

resource "google_project_service" "compute" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false

  # Use count to make this resource conditional
  count = var.enable_apis ? 1 : 0
}
