# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

# IAM Outputs
output "eks_cluster_role_arn" {
  description = "ARN of EKS cluster role"
  value       = module.iam_base.eks_cluster_role_arn
}

output "eks_nodes_role_arn" {
  description = "ARN of EKS nodes role"
  value       = module.iam_base.eks_nodes_role_arn
}

output "cluster_autoscaler_role_arn" {
  description = "ARN of Cluster Autoscaler role"
  value       = module.iam_irsa.cluster_autoscaler_role_arn
}

output "aws_load_balancer_controller_role_arn" {
  description = "ARN of AWS Load Balancer Controller role"
  value       = module.iam_irsa.aws_load_balancer_controller_role_arn
}

# EKS Outputs
output "eks_cluster_id" {
  description = "EKS cluster name"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_id}"
}

# RDS Outputs
output "rds_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_instance_endpoint
}

output "rds_secret_arn" {
  description = "ARN of RDS credentials secret"
  value       = module.rds.secret_arn
}
