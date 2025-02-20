output "pod_identity_role_arn" {
  description = "ARN of the Pod Identity role for ArgoCD"
  value       = aws_iam_role.argocd_pod_identity_role.arn
}

output "cluster_role_arns" {
  description = "Map of cluster names to their role ARNs"
  value       = { for k, v in aws_iam_role.cluster_roles : k => v.arn }
} 
