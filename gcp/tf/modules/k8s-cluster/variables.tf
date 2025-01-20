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

variable "node_count" {
  type        = number
  description = "Number of nodes in the cluster"
}

variable "machine_type" {
  type        = string
  description = "Machine type for the nodes"
}
variable "enable_autopilot" {
  description = "Enable Autopilot for this cluster"
  type        = bool
  default     = false
}