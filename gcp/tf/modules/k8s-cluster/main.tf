data "google_client_config" "default" {}
data "google_project" "project" {
  project_id = var.project_id
}

# Create GKE cluster
resource "google_container_cluster" "main" {
  name     = var.name
  location = var.location
  # Workload Identity is a feature that allows you to associate a Kubernetes service account with a Google Cloud service account.
  # We need to enable Workload Identity on the cluster in order to use the Secret Store CSI Driver Provider for GCP.
  # https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
  # https://cloud.google.com/secret-manager/docs/using-other-products#google-kubernetes-engine
  workload_identity_config {
    workload_pool = "${data.google_project.project.project_id}.svc.id.goog"
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
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
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = google_container_cluster.main.name
  location   = var.location
  cluster    = google_container_cluster.main.name
  node_count = var.node_count

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = var.machine_type
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  depends_on = [
    resource.google_container_cluster.main
  ]
}
