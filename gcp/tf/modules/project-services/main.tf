locals {
  # Base APIs that are either required or just very common and useful.
  base_apis = [
    "compute.googleapis.com", // Required for GKE
    "container.googleapis.com", // Required for GKE
    "artifactregistry.googleapis.com", // Required for Docker image registry, required unless using a different image registry (not currently supported in this TF template)
    "monitoring.googleapis.com", // Enable Google Cloud Monitoring, optional
    "cloudtrace.googleapis.com", // Enable Google Cloud Trace, optional
    "cloudprofiler.googleapis.com", // Enable Google Cloud Profiler, optional
    "cloudresourcemanager.googleapis.com", // Required for resource management
    "secretmanager.googleapis.com" // Enable Google Cloud Secret Manager, optional
  ]
}


# Enable Google Cloud APIs
module "project_services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 18.0"

  project_id                  = var.project_id
  enable_apis                 = var.enable_apis
  disable_services_on_destroy = false

  activate_apis = local.base_apis
}
