output "cluster_autoscaler_role_arn" {
  description = "ARN of the Cluster Autoscaler IAM role"
  value       = var.enable_cluster_autoscaler ? aws_iam_role.cluster_autoscaler[0].arn : ""
}

output "aws_load_balancer_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM role"
  value       = var.enable_alb_controller ? aws_iam_role.aws_load_balancer_controller[0].arn : ""
}

output "cluster_autoscaler_policy_arn" {
  description = "ARN of the Cluster Autoscaler policy"
  value       = var.enable_cluster_autoscaler ? aws_iam_policy.cluster_autoscaler[0].arn : ""
}

output "aws_load_balancer_controller_policy_arn" {
  description = "ARN of the AWS Load Balancer Controller policy"
  value       = var.enable_alb_controller ? aws_iam_policy.aws_load_balancer_controller[0].arn : ""
}
