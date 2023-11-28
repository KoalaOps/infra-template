output "network_name" {
  description = "Name of the network"
  value       = module.vpc.name
}
output "network_id" {
  description = "Id of the network"
  value       = module.vpc.vpc_id
}
output "private_subnets" {
  description = "private_subnets"
  value       = module.vpc.private_subnets
}