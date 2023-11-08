
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.57.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}


# We use this data provider to expose an access token for communicating with the GKE cluster.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config
data "google_client_config" "client" {}

provider "kubernetes" {
  host                   = module.k8s_cluster.endpoint
  token                  = data.google_client_config.client.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.k8s_cluster.master_auth[0].cluster_ca_certificate)
}

provider "kubectl" {
  host                   = module.k8s_cluster.endpoint
  token                  = data.google_client_config.client.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.k8s_cluster.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.k8s_cluster.endpoint
    token                  = data.google_client_config.client.access_token
    cluster_ca_certificate = module.k8s_cluster.cluster_ca_certificate
  }
}
