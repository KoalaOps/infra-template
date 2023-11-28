output "network_name" {
  description = "Name of the network"
  value       = module.network.network_name
}

output "subnet_names" {
  description = "Names of the subnets"
  value       = module.network.subnet_names
}
