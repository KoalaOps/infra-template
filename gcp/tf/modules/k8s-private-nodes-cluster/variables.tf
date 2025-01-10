variable "project_resource_prefix" {
  type        = string
  description = "The project resource prefix"
}

variable "location" {
  type        = string
  description = "Location of the cluster"
}

variable "name" {
  type        = string
  description = "Name given to the new cluster"
}

variable "network" {
  type        = string
  description = "The VPC network name"
}

variable "subnet" {
  type        = string
  description = "The VPC subnet name"
}

variable "min_node_count" {
  type        = number
  description = "Minimum number of nodes per zone in the node pool. Must be >=0 and <= max_node_count. Cannot be used with total limits."
  default = 1
}

variable "max_node_count" {
  type        = number
  description = "Maximum number of nodes per zone in the node pool. Must be >= min_node_count. Cannot be used with total limits."
  default = 2
}

variable "machine_type" {
  type        = string
  description = "Machine type for the nodes"
}