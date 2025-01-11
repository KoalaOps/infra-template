variable "project_id" {
  type        = string
  description = "The project ID to deploy the cluster in"
}

variable "project_name" {
  type        = string
  description = "The project name"
}

variable "location" {
  type        = string
  description = "Location of the cluster"
}

variable "regions" {
  type        = list(string)
  description = "Regions where we want to deploy the network"
}

variable "region" {
  type        = string
  description = "The cluster's region"
}

variable "zone" {
  type        = string
  description = "The cluster's zone"
}

variable "image_repo_id" {
  type        = string
  description = "The ID of the docker image repository"
  default     = null
}

variable "cluster_name" {
  type        = string
  description = "Name given to the new cluster"
  default     = null
}

variable "node_count" {
  type        = number
  description = "Number of nodes in the cluster"
}

variable "machine_type" {
  type        = string
  description = "Machine type for the nodes"
}
