variable "cluster_name" {
  type        = string
  description = "Name given to the new cluster"
}

variable "network" {
  type        = string
  description = "The VPC network name"
}

variable "subnet" {
  type        = list(string)
  description = "The VPC subnet name"
}

variable "node_groups" {
  type        = any
  description = "Map of node groups configuration. Each node group can have desired_capacity, max_capacity, min_capacity, instance_type, instance_types, capacity_type, ami_type, max_unavailable, tags, and name."
  default = {
    primary = {
      # Production-ready scaling configuration
      desired_capacity = 2
      max_capacity     = 10
      min_capacity     = 2 # Minimum 2 nodes for high availability

      # Instance configuration
      instance_type = "t3.medium"
      # instance_types = ["t3.medium", "t3.large"]  # Optional: specify multiple instance types

      # Optional configurations (will use defaults if not specified)
      # capacity_type = "ON_DEMAND"  # or "SPOT"
      # ami_type = "AL2_x86_64"
      # max_unavailable = 1
      # name = "custom-node-group-name"

      # Optional tags
      tags = {
        Environment = "production"
        NodeGroup   = "primary"
      }
    }
  }
}

variable "node_tag" {
  type        = string
  description = "Machine tag for nodes"
}

variable "allow_management_cluster_access" {
  type        = bool
  description = "Whether to allow access from management cluster security group"
  default     = true
}

variable "management_cluster_sg_id" {
  type        = string
  description = "Security group ID of the management cluster"
  default     = ""
}

variable "default_instance_types" {
  type        = list(string)
  description = "Default instance types for node groups"
  default     = ["t3.medium"]
}

variable "default_capacity_type" {
  type        = string
  description = "Default capacity type for node groups (ON_DEMAND or SPOT)"
  default     = "ON_DEMAND"
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.default_capacity_type)
    error_message = "Capacity type must be either ON_DEMAND or SPOT."
  }
}

variable "default_desired_capacity" {
  type        = number
  description = "Default desired capacity for node groups"
  default     = 2
  validation {
    condition     = var.default_desired_capacity >= 1
    error_message = "Desired capacity must be at least 1."
  }
}

variable "default_min_capacity" {
  type        = number
  description = "Default minimum capacity for node groups"
  default     = 2
  validation {
    condition     = var.default_min_capacity >= 1
    error_message = "Minimum capacity must be at least 1. For high availability, consider using 2 or more nodes."
  }
}

variable "default_max_capacity" {
  type        = number
  description = "Default maximum capacity for node groups"
  default     = 10
  validation {
    condition     = var.default_max_capacity >= 1
    error_message = "Maximum capacity must be at least 1."
  }
}
