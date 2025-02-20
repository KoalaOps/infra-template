variable "project_name" {
  type        = string
  description = "Name of the project, used for naming resources"
}

variable "managed_cluster_names" {
  type        = list(string)
  description = "List of cluster names that will be managed by ArgoCD"
}

variable "management_cluster_name" {
  type        = string
  description = "Name of the EKS cluster where ArgoCD is running"
} 
