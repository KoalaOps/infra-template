
# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = "false"
}

# Primary subnet for GKE.
# This is the IP address range that GKE uses to allocate IP addresses for internal load balancers and nodes.
resource "google_compute_subnetwork" "subnet" {
  // Iterate over the list of regions and create a subnet for each one.
  for_each      = toset(var.regions)
  name          = "${var.project_id}-subnet"
  region        = each.value
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.${index(var.regions, each.value)*2 + 10}.0.0/20"
}
