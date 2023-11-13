# Description: Production environment

module "project_services" {
  source      = "../../modules/project-services"
  project_id  = var.project_id
  enable_apis = true
}


# Introduce a delay with a null_resource that depends on the artifactregistry API being enabled,
# to allow time for the API to be enabled before creating the image registry.
resource "null_resource" "wait_for_artifact_registry" {
  triggers = {
    artifactregistry = module.project_services.artifactregistry
  }

  # Delay is triggered after the artifact_registry service is created.
  depends_on = [
    module.project_services.artifactregistry
  ]

  provisioner "local-exec" {
    when    = create
    command = "sleep 60" # Wait for 60 seconds
  }
}

# Introduce a delay with a null_resource that depends on the compute API being enabled,
# to allow time for the API to be enabled before creating the network.
resource "null_resource" "wait_for_compute" {
  triggers = {
    compute = module.project_services.compute
  }

  # Delay is triggered after the compute service is created.
  depends_on = [
    module.project_services.compute
  ]

  provisioner "local-exec" {
    when    = create
    command = "sleep 60" # Wait for 60 seconds
  }
}

module "image_registry" {
  source        = "../../modules/image-registry"
  project_id    = var.project_id
  location      = var.region
  image_repo_id = var.image_repo_id

  depends_on = [
    null_resource.wait_for_artifact_registry
  ]
}

module "network" {
  source     = "../../modules/network"
  project_id = var.project_id
  regions    = var.regions

  depends_on = [
    null_resource.wait_for_compute
  ]
}

module "k8s_cluster" {
  source        = "../../modules/k8s-cluster"
  project_id    = var.project_id
  location      = var.location
  image_repo_id = var.image_repo_id
  name          = var.cluster_name
  node_count    = var.node_count
  machine_type  = var.machine_type
  network       = module.network.network_name
  subnet        = module.network.subnet_names[var.region]
}
