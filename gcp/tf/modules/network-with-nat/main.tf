# This module creates a VPC with NAT gateways in the specified locations.

# VPC
resource "google_compute_network" "vpc" {
  name                    = var.project_resource_prefix
  auto_create_subnetworks = "false"
}

# Primary subnet for GKE.
# This is the IP address range that GKE uses to allocate IP addresses for internal load balancers and nodes.
resource "google_compute_subnetwork" "subnet" {
  // Iterate over the list of regions and create a subnet for each one.
  for_each      = toset(var.locations)
  name          = "${var.project_resource_prefix}-${each.value}"
  region        = each.value
  network       = google_compute_network.vpc.name
  # The IP address range for the subnet is based on the index of the location in the list of locations.
  # This is a simple way to ensure that the IP address ranges do not overlap.
  # The first location gets 10.10.0.0/20, the second location gets 10.12.0.0/20, etc.
  ip_cidr_range = "10.${index(var.locations, each.value) * 2 + 10}.0.0/20"
}

# Allocate external IP addresses for the NAT gateways, one per location, to be used for the NAT gateways.
# Uses GCP's Premium tier, which is required for NAT gateways.
resource "google_compute_address" "nat_ips" {
  for_each     = toset(var.locations)
  name         = "${var.project_resource_prefix}-${each.value}"
  project      = var.project_id
  region       = each.value
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}

# Create a router for each location.
# A router is required for each NAT gateway.
resource "google_compute_router" "nat_routers" {
  for_each = toset(var.locations)
  name     = "${var.project_resource_prefix}-${each.value}"
  network  = google_compute_network.vpc.name
  region   = each.value
  project  = var.project_id
}

# Create a NAT gateway for each location.
# A NAT gateway is required for each subnet.
# The NAT gateway uses the external IP address allocated for the location.
# The NAT gateway is configured to use all subnets in the VPC. This can be changed if you only want the NAT gateway to be used for specific subnets.
# The NAT gateway is configured to log errors only.
resource "google_compute_router_nat" "nat_gateways" {
  for_each                           = toset(var.locations)
  name                               = "${var.project_resource_prefix}-${each.value}"
  router                             = google_compute_router.nat_routers[each.key].name
  region                             = each.value
  project                            = var.project_id
  nat_ip_allocate_option             = "MANUAL_ONLY" // Set to "AUTO_ONLY" if you want GCP to automatically allocate external IP addresses for the NAT gateways.
  nat_ips                            = [google_compute_address.nat_ips[each.key].id]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES" // Set to "LIST_OF_SUBNETWORKS" if you only want the NAT gateway to be used for specific subnets.

  log_config {
    enable = true // Enable logging of NAT gateway activity
    filter = "ERRORS_ONLY" // Only log errors, to avoid excessive logging. Switch to "ALL" if you want to log all activity.
  }
}
