variable "project_id" {
  type        = string
  description = "The project ID to deploy the registry in"
}

variable "location" {
  type        = string
  description = "Location of the registry"
}

variable "image_repo_id" {
  type        = string
  description = "The ID of the docker image repository"
}