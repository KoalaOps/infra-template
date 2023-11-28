output "network_name" {
  description = "Name of the network"
  value       = google_compute_network.vpc.name
}
output "subnet_names" {
  description = "Name of the subnets"
  value = {
    for subnet in google_compute_subnetwork.subnet: subnet.region => subnet.name
  }
}