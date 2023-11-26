variable "project_id" {
  type        = string
  description = "The project ID to deploy the cluster in"
}

variable "location" {
  type        = string
  description = "Location of the cluster"
}

variable "region" {
  type        = string
  description = "The cluster's region"
}

variable "zone" {
  type        = string
  description = "The cluster's zone"
}

variable "cluster_name" {
  type        = string
  description = "Name given to the new cluster"
}

variable "node_count" {
  type        = number
  description = "Number of nodes in the cluster"
}

variable "machine_type" {
  type        = string
  description = "Machine type for the nodes"
}

# variable "redis_tier" {
#   type        = string
#   description = "Redis tier, BASIC or STANDARD"
# }
# variable "redis_version" {
#   type        = string
#   description = "Redis version"
# }
# variable "redis_memory_size" {
#   type        = number
#   description = "Redis memory size in GB"
# }
