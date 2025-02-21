# Create the Pod Identity role for ArgoCD
resource "aws_iam_role" "argocd_pod_identity_role" {
  name = "${var.project_name}-argocd-pod-identity"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Condition = {
          StringEquals = {
            "eks:cluster-name" : var.management_cluster_name
          }
        }
      }
    ]
  })
}

# Add permission to assume cluster roles
resource "aws_iam_role_policy" "argocd_assume_cluster_roles" {
  name = "assume-cluster-roles"
  role = aws_iam_role.argocd_pod_identity_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = {
      Effect   = "Allow"
      Action   = "sts:AssumeRole"
      Resource = "arn:aws:iam::*:role/*-cluster-role"
    }
  })
}

# Create cluster-specific roles that can be assumed by the ArgoCD Pod Identity role
resource "aws_iam_role" "cluster_roles" {
  for_each = toset(var.managed_cluster_names)

  name = "${var.project_name}-${each.key}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.argocd_pod_identity_role.arn
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Create EKS access entries for cluster roles
resource "aws_eks_access_entry" "cluster_access" {
  for_each = toset(var.managed_cluster_names)

  cluster_name      = each.key
  principal_arn     = aws_iam_role.cluster_roles[each.key].arn
  type              = "STANDARD"
  kubernetes_groups = []
}

resource "aws_eks_access_policy_association" "cluster_admin" {
  for_each = toset(var.managed_cluster_names)

  cluster_name = each.key
  policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
  principal_arn = aws_iam_role.cluster_roles[each.key].arn

  depends_on = [aws_eks_access_entry.cluster_access]
}
