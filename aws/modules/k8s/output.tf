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
