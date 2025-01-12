output "name" {
  description = "Name of the cluster"
  value       = google_container_cluster.main.name
}

output "endpoint" {
  description = "The IP address of the cluster master."
  sensitive   = true
  value       = google_container_cluster.main.endpoint
}

output "cluster" {
  description = "The k8s cluster"
  value       = google_container_cluster.main
  sensitive   = true
}

# The following outputs allow authentication and connectivity to the GKE Cluster.
output "client_certificate" {
  description = "Public certificate used by clients to authenticate to the cluster endpoint."
  value       = base64decode(google_container_cluster.main.master_auth[0].client_certificate)
}
output "client_key" {
  description = "Private key used by clients to authenticate to the cluster endpoint."
  value       = base64decode(google_container_cluster.main.master_auth[0].client_key)
  sensitive   = true
}
output "cluster_ca_certificate" {
  description = "The public certificate that is the root of trust for the cluster."
  value       = base64decode(google_container_cluster.main.master_auth[0].cluster_ca_certificate)
  sensitive   = false
}
