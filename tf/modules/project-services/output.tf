output "enabled_apis" {
  description = "List of enabled Google Cloud APIs for the project"
  value       = module.project_services.enabled_apis
}


output "artifactregistry" {
  description = "Artifact Registry API"
  value       = google_project_service.artifactregistry
}

output "compute" {
    description = "Compute Engine API"
    value       = google_project_service.compute
}