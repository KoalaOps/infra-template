# # Get credentials for cluster
# module "gcloud" {
#   source  = "terraform-google-modules/gcloud/google"
#   version = "~> 3.0"

#   platform              = "linux"
#   additional_components = ["kubectl", "beta"]

#   create_cmd_entrypoint = "gcloud"
#   # Use local variable cluster_name for an implicit dependency on resource "google_container_cluster" 
#   create_cmd_body = "container clusters get-credentials ${local.cluster_name} --zone=${var.location}"
# }

# # Apply YAML files for cluster level configurations (ArgoCD, Argo Rollout, ingress-nginx, namespaces, etc)
# resource "null_resource" "apply_cluster_manifests" {
#   triggers = {
#     always_run = "${timestamp()}"
#   }

#   provisioner "local-exec" {
#     interpreter = ["bash", "-exc"]
#     command     = "/bin/bash setup_cluster_yaml_files.sh"
#   }

#   depends_on = [
#     module.gcloud
#   ]
# }