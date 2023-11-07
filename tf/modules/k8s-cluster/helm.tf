# resource "helm_release" "cert-manager" {
#   count            = var.install-cert-manager ? 1 : 0
#   name             = "cert-manager"
#   repository       = "https://charts.jetstack.io"
#   chart            = "cert-manager"
#   version          = "v1.11.0"
#   namespace        = "cert-manager"
#   create_namespace = true

#   set {
#     name  = "installCRDs"
#     value = "true"
#   }
# }

# resource "helm_release" "nginx-ingress" {
#   count            = var.install-nginx-ingress ? 1 : 0
#   name             = "nginx-ingress"
#   repository       = "https://kubernetes.github.io/ingress-nginx"
#   chart            = "ingress-nginx"
#   namespace        = "ingress-nginx"
#   create_namespace = true
#   // add monitoring
#   set {
#     name  = "controller.metrics.enabled"
#     value = "true"
#   }
#   set {
#     name  = "controller.metrics.serviceMonitor.enabled"
#     value = "true"
#   }
#   set {
#     name  = "controller.metrics.serviceMonitor.namespace"
#     value = "monitoring"
#   }
#   set {
#     name  = "controller.metrics.serviceMonitor.additionalLabels.release"
#     value = var.kube-prometheus-name
#   }
# }

# resource "helm_release" "kube_prometheus" {
#   count            = var.install-kube-prometheus ? 1 : 0
#   name             = var.kube-prometheus-name
#   repository       = "https://prometheus-community.github.io/helm-charts"
#   chart            = "kube-prometheus-stack"
#   namespace        = "monitoring"
#   create_namespace = true
# }
