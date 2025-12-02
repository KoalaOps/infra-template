# ---------------------------
#  Outputs
# ---------------------------

output "project_number" {
  description = "Numeric project number — useful for GitHub Actions auth"
  value       = data.google_project.this.number
}

output "service_account" {
  description = "Email of the service account to impersonate"
  value       = google_service_account.deployer.email
}

output "workload_identity_provider" {
  description = "Full resource name of the Workload Identity Provider"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "artifact_registry_repository" {
  description = "Full name of the created Artifact Registry repository"
  value       = google_artifact_registry_repository.docker_repo.name
}

output "docker_registry_url" {
  description = "Docker registry URL for pushing images"
  value       = "${var.artifact_registry_location}-docker.pkg.dev/${var.project_id}/${var.artifact_registry_repository_name}"
}

# Example GitHub Actions usage (documentation only):
# with:
#   project_number: ${{ steps.gcp.outputs.project_number }}
#   service_account: ${{ steps.gcp.outputs.service_account }}
#   workload_identity_provider: ${{ steps.gcp.outputs.workload_identity_provider }} 