variable "project_id" {
  type        = string
  description = "The project ID to deploy the cluster in"
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

variable "image_repo_id" {
  type        = string
  description = "The ID of the docker image repository"
}

variable "node_count" {
  type        = number
  description = "Number of nodes in the cluster"
}

variable "machine_type" {
  type        = string
  description = "Machine type for the nodes"
}

variable "install-cert-manager" {
  type        = bool
  description = "Install cert-manager"
  default     = true
}

variable "install-nginx-ingress" {
  type        = bool
  description = "Install nginx-ingress"
  default     = true
}

variable "install-kube-prometheus" {
  type        = bool
  description = "Install kube-prometheus"
  default     = true
}

variable "kube-prometheus-name" {
  type        = string
  description = "The name of the kube-prometheus release"
  default     = "kube-prometheus"
}

variable "install-secrets-store-csi-driver" {
  type        = bool
  description = "Install secrets-store-csi-driver"
  default     = true
}
