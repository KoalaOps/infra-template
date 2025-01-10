
# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.project_resource_prefix}"
  auto_create_subnetworks = "false"
}

# Primary subnet for GKE.
# This is the IP address range that GKE uses to allocate IP addresses for internal load balancers and nodes.
resource "google_compute_subnetwork" "subnet" {
  // Iterate over the list of regions and create a subnet for each one.
  for_each      = toset(var.locations)
  name                    = "${var.project_resource_prefix}-${each.value}"
  region        = each.value
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.${index(var.locations, each.value)*2 + 10}.0.0/20"
}




resource "google_compute_address" "nat_ips" {
  for_each     = toset(var.locations)
  name         = "${var.project_resource_prefix}-${each.value}"
  project      = var.project_id
  region       = each.value
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}

resource "google_compute_router" "nat_routers" {
  for_each = toset(var.locations)
  name     = "${var.project_resource_prefix}-${each.value}"
  network  = google_compute_network.vpc.name
  region   = each.value
  project  = var.project_id
}

resource "google_compute_router_nat" "nat_gateways" {
  for_each                           = toset(var.locations)
  name                               = "${var.project_resource_prefix}-${each.value}"
  router                             = google_compute_router.nat_routers[each.key].name
  region                             = each.value
  project                            = var.project_id
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat_ips[each.key].id]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}