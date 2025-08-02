# ---------------------------
#  Input variables
# ---------------------------

variable "project_id" {
  description = "GCP Project ID where resources will be created"
  type        = string
}

variable "github_org" {
  description = "GitHub organization (owner) name to grant impersonation to all its repositories"
  type        = string
}

variable "region" {
  description = "Google Cloud location for the Workload Identity Pool"
  type        = string
}

variable "artifact_registry_location" {
  description = "Location for the Artifact Registry repository"
  type        = string
}

variable "artifact_registry_repository_name" {
  description = "Name of the Artifact Registry repository"
  type        = string
} 