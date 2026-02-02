output "eks_control_plane_security_group_id" {
  description = "Security group ID for EKS control plane"
  value = aws_security_group.eks_control_plane.id
}

output "eks_nodes_security_group_id" {
  description = "Security group ID for EKS worker nodes"
  value = aws_security_group.eks_nodes.id
}

output "rds_security_group_id" {
  description = "Security group ID for RDS database"
  value = aws_security_group.rds.id
}

output "alb_security_group_id" {
  description = "Security group ID for Application Load Balancer"
  value = aws_security_group.alb.id
}
