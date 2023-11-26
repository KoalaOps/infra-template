# Google Artifact Registry
resource "google_artifact_registry_repository" "image-repo" {
  location      = var.location
  project       = var.project_id
  repository_id = var.image_repo_id
  description   = "Docker image registry"
  format        = "DOCKER"
}
