# ----------------------------------------------------------------------------
#  Workload Identity Federation for GitHub Actions  — Terraform configuration
#  fully declarative.
# ----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.2"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

# ---------------------------
#  Providers & project data
# ---------------------------

provider "google" {
  project = var.project_id
}

data "google_project" "this" {
  project_id = var.project_id
}

# ---------------------------
#  Enable required APIs
# ---------------------------

resource "google_project_service" "iamcredentials" {
  project = var.project_id
  service = "iamcredentials.googleapis.com"
}

resource "google_project_service" "sts" {
  project = var.project_id
  service = "sts.googleapis.com"
}

resource "google_project_service" "artifactregistry" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "container" {
  project = var.project_id
  service = "container.googleapis.com"
}

# ---------------------------
#  Naming conventions
# ---------------------------

locals {
  pool_name      = "gh-pool-${var.project_id}-v1"
  provider_name  = "gh-prov-${var.project_id}-v1"
  sa_name        = "gh-deploy-${var.project_id}"
  sa_email       = "${local.sa_name}@${var.project_id}.iam.gserviceaccount.com"
}

# ---------------------------
#  Workload Identity Pool
# ---------------------------

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = local.pool_name
  display_name             = "GitHub WIF Pool"
  description              = "Workload Identity Pool for GitHub Actions"
  project                  = var.project_id

  depends_on = [
    google_project_service.iamcredentials,
    google_project_service.sts
  ]
}

# ---------------------------
#  OIDC Provider in the Pool
# ---------------------------

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = local.provider_name
  project                            = var.project_id

  display_name = "GitHub Provider"
  description  = "GitHub Actions OIDC provider for organization ${var.github_org}"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"            = "assertion.sub"
    "attribute.repository"      = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
    "attribute.actor"           = "assertion.actor"
  }

  attribute_condition = "assertion.repository_owner=='${var.github_org}'"
}

# ---------------------------
#  Service Account that will be impersonated by GitHub
# ---------------------------

resource "google_service_account" "deployer" {
  account_id   = local.sa_name
  display_name = "GitHub WIF Deployer"
  description  = "Service account for GitHub Actions deployment"
  project      = var.project_id
}

# ---------------------------
#  Project-level IAM roles for the service account
# ---------------------------

# Core container and registry permissions
resource "google_project_iam_member" "deployer_container_dev" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_project_iam_member" "deployer_container_viewer" {
  project = var.project_id
  role    = "roles/container.clusterViewer"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_project_iam_member" "deployer_artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_project_iam_member" "deployer_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

# Build and deployment permissions
resource "google_project_iam_member" "deployer_cloudbuild_editor" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.editor"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_project_iam_member" "deployer_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

# Observability permissions
resource "google_project_iam_member" "deployer_logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_project_iam_member" "deployer_monitoring_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

# ---------------------------
#  Allow GitHub repo to impersonate the service account
# ---------------------------

resource "google_service_account_iam_member" "github_workload_identity" {
  service_account_id = google_service_account.deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository_owner/${var.github_org}"
}

resource "google_service_account_iam_member" "github_token_creator" {
  service_account_id = google_service_account.deployer.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository_owner/${var.github_org}"
}

# ---------------------------
#  Artifact Registry Repository
# ---------------------------

resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.artifact_registry_location
  repository_id = var.artifact_registry_repository_name
  description   = "Docker repository for ${var.github_org}"
  format        = "DOCKER"
  project       = var.project_id

  depends_on = [google_project_service.artifactregistry]
} 