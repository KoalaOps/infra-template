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
  description = "map of node groups config"
  default = {
    node_group_one = {
      desired_capacity = 3
      max_capacity     = 50
      min_capacity     = 2

      instance_type = "t3.medium"

     #tags         = ["aws-node"]
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
