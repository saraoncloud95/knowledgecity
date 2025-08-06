output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_oidc_issuer_url" {
  description = "EKS cluster OIDC issuer URL"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "cluster_oidc_provider_arn" {
  description = "EKS cluster OIDC provider ARN"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "cluster_autoscaler_role_arn" {
  description = "Cluster autoscaler IAM role ARN"
  value       = aws_iam_role.cluster_autoscaler.arn
}

output "node_groups" {
  description = "Map of EKS node groups"
  value       = aws_eks_node_group.main
} 