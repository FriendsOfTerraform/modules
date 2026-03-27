locals {
  cluster_region = split(":", aws_eks_cluster.eks_cluster.arn)[3]
  cluster_name   = aws_eks_cluster.eks_cluster.id
}

output "cluster_arn" {
  description = <<EOT
    The ARN of the EKS cluster
    
    @type string
    @since 1.0.0
  EOT
  value       = aws_eks_cluster.eks_cluster.arn
}

output "cluster_certificate_authority" {
  description = <<EOT
    The public CA certificate (based64) of the EKS cluster
    
    @type string
    @since 1.0.0
  EOT
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "cluster_endpoint_url" {
  description = <<EOT
    The endpoint URL of the EKS cluster
    
    @type string
    @since 1.0.0
  EOT
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_name" {
  description = <<EOT
    The name of the EKS cluster
    
    @type string
    @since 1.1.0
  EOT
  value       = aws_eks_cluster.eks_cluster.id
}

output "cluster_role_arn" {
  description = <<EOT
    The ARN of the cluster IAM role
    
    @type string
    @since 1.1.0
  EOT
  value       = aws_iam_role.eks_cluster_role.arn
}

output "node_group_arns" {
  description = <<EOT
    Map of ARNs of all the node groups associated to this cluster
    
    @type map(string)
    @since 1.0.0
  EOT
  value       = { for k, v in aws_eks_node_group.eks_node_groups : k => v.arn }
}

output "node_role_arn" {
  description = <<EOT
    The ARN of the node IAM role
    
    @type string
    @since 1.1.0
  EOT
  value       = aws_iam_role.eks_node_instance_role.arn
}

output "aws_cli_connect_to_cluster_command" {
  description = <<EOT
    The AWS cli command to connect to the EKS cluster
    
    @type string
    @since 1.0.0
  EOT
  value       = "aws eks --region ${local.cluster_region} update-kubeconfig --name ${local.cluster_name}"
}