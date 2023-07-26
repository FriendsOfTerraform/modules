locals {
  cluster_region = split(":", aws_eks_cluster.eks_cluster.arn)[3]
  cluster_name   = aws_eks_cluster.eks_cluster.id
}

output "cluster_arn" {
  value = aws_eks_cluster.eks_cluster.arn
}

output "cluster_certificate_authority" {
  value = aws_eks_cluster.eks_cluster.certificate_authority
}

output "cluster_endpoint_url" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.id
}

output "node_group_arns" {
  value = { for k, v in aws_eks_node_group.eks_node_groups : k => v.arn }
}

output "aws_cli_connect_to_cluster_command" {
  value = "aws eks --region ${local.cluster_region} update-kubeconfig --name ${local.cluster_name}"
}