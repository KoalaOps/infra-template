data "google_client_config" "default" {}
data "google_project" "project" {
  project_id = var.project_id
}

# Create GKE cluster
resource "google_container_cluster" "main" {
  # Docs: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster.html
  name     = var.name
  location = var.location
  # Workload Identity is a feature that allows you to associate a Kubernetes service account with a Google Cloud service account.
  # This is highly recommended, as it allows for more secure and flexible authentication and authorization, for example
  # to manage access to Google Cloud resources from within the cluster.
  # https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
  # https://cloud.google.com/secret-manager/docs/using-other-products#google-kubernetes-engine
  workload_identity_config {
    workload_pool = "${data.google_project.project.project_id}.svc.id.goog"
  }

  # We want to separately manage the node pool(s) for more control over the nodes.
  # We can't create a cluster with no node pool defined, so we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network
  subnetwork = var.subnet

  # Set IP allocation policy to ensure alias IPs are used (VPC-native mode).
  # https://cloud.google.com/kubernetes-engine/docs/concepts/alias-ips
  ip_allocation_policy {
    # Let GKE choose the default ranges for us
    cluster_ipv4_cidr_block  = ""
    services_ipv4_cidr_block = ""
  }

  # Enable Google Cloud Monitoring Managed Service for Prometheus
  # https://cloud.google.com/stackdriver/docs/managed-prometheus
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS", "APISERVER", "CONTROLLER_MANAGER", "SCHEDULER"]
    managed_prometheus {
      enabled = true
    }
  }

  # It is recommended to set a maintenance policy, to avoid disruption at unexpected times.
  # https://cloud.google.com/kubernetes-engine/docs/how-to/maintenance-windows-and-exclusions
  # Example maintenance policy:
  # maintenance_policy {
  #   recurring_window {
  #       end_time   = "2024-12-09T12:00:00Z"
  #       recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
  #       start_time = "2024-12-09T06:00:00Z"
  #     }
  # }

  # Locations (zones) in which the nodes will be created.
  # Only applicable if location is a region (contains exactly 1 dash)
  # Otherwise, the cluster is Zonal (i.e. only 1 zone, not recommended for production clusters)
  node_locations = length(split("-", var.location)) == 1 ? ["${var.location}-a", "${var.location}-b"] : null

  # Enable network policy, which allows you to control the network traffic between pods and services.
  # This may be required for enhanced security, but is not necessarily needed for all clusters.
  # https://cloud.google.com/kubernetes-engine/docs/how-to/network-policy
  # network_policy {
  #   enabled = true
  # }

  # Enable private nodes (no external IPs)
  # Enhanced security, may be required for compliance reasons, but increases complexity.
  private_cluster_config {
    # Enable private nodes, i.e. no external IPs for the nodes themselves. 
    # To access the internet, they will need to use a NAT gateway.
    enable_private_nodes    = true
    # Disable the public endpoint for the cluster, i.e. no public IP address for the k8s API server.
    # This is sometimes required for compliance reasons, but can increase complexity as users need
    # to use a VPN or other means such as a bastion host to access the cluster.
    enable_private_endpoint = false
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name     = google_container_cluster.main.name
  location = var.location
  cluster  = google_container_cluster.main.name

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write", // Enable Google Cloud Logging
      "https://www.googleapis.com/auth/monitoring", // Enable Google Cloud Monitoring
      "https://www.googleapis.com/auth/cloud-platform" // Enable Google Cloud Platform API, so that nodes can access Google Cloud services
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = var.machine_type
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
      block-project-ssh-keys   = "true" # Added line to block project-wide SSH keys
    }
  }

  depends_on = [
    resource.google_container_cluster.main
  ]
}
