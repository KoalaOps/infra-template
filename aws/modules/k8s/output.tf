output "name" {
  description = "Name of the cluster"
  value       = module.eks.cluster_name
}

output "id" {
  description = "ID of the cluster"
  value       = module.eks.cluster_id
}

output "endpoint" {
  description = "The IP address of the cluster master."
  sensitive   = true
  value       = module.eks.cluster_endpoint
}

output "node_security_group_id" {
  description = "Security group ID of the cluster nodes"
  value       = module.eks.node_security_group_id
}
