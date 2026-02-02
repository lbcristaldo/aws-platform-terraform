# Security Module - Security Groups and Network ACLs
# Implements defense-in-depth network security

# Security Group for EKS Control Plane
resource "aws_security_group" "eks_control_plane" {
  name_prefix = "${var.project_name}-eks-control-plane-"
  description = "Security group for EKS control plane communication with worker nodes"
  vpc_id      = var.vpc_id
  
  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-eks-control-plane-sg"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for EKS Worker Nodes
resource "aws_security_group" "eks_nodes" {
  name_prefix = "${var.project_name}-eks-nodes-"
  description = "Security group for all nodes in the EKS cluster"
  vpc_id      = var.vpc_id
  
  tags = merge(
    var.tags,
    {
      Name                                 = "${var.project_name}-eks-nodes-sg"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# Allow nodes to communicate with each other
resource "aws_security_group_rule" "nodes_internal" {
  description              = "Allow nodes to communicate with each other"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

# Allow worker nodes to receive communication from control plane
resource "aws_security_group_rule" "nodes_control_plane" {
  description              = "Allow worker kubelets and pods to receive communication from control plane"
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_control_plane.id
}

# Allow control plane to receive communication from worker nodes
resource "aws_security_group_rule" "control_plane_nodes" {
  description              = "Allow pods to communicate with the control plane API server"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_control_plane.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

# Allow all outbound traffic from nodes
resource "aws_security_group_rule" "nodes_egress" {
  description       = "Allow all outbound traffic from worker nodes"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes.id
}

# Security Group for RDS Database
resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-rds-"
  description = "Security group for PostgreSQL database"
  vpc_id      = var.vpc_id
  
  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-rds-sg"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# Allow RDS access from EKS nodes only
resource "aws_security_group_rule" "rds_from_eks" {
  description              = "Allow PostgreSQL access from EKS worker nodes"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

# Security Group for Application Load Balancer
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-alb-"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id
  
  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-alb-sg"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# Allow HTTPS traffic from internet to ALB
resource "aws_security_group_rule" "alb_https_ingress" {
  description       = "Allow HTTPS from internet"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

# Allow HTTP from internet to ALB (for redirect to HTTPS)
resource "aws_security_group_rule" "alb_http_ingress" {
  description       = "Allow HTTP from internet (for HTTPS redirect)"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

# Allow ALB to communicate with EKS nodes
resource "aws_security_group_rule" "alb_to_nodes" {
  description              = "Allow ALB to communicate with EKS nodes"
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

# Allow nodes to receive traffic from ALB
resource "aws_security_group_rule" "nodes_from_alb" {
  description              = "Allow worker nodes to receive traffic from ALB"
  type                     = "ingress"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.alb.id
}

# Network ACL for additional layer of security (optional but recommended)
resource "aws_network_acl" "private" {
  count = var.enable_nacls ? 1 : 0
  
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids
  
  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-private-nacl"
    }
  )
}

# NACL rule: Allow all inbound from VPC CIDR
resource "aws_network_acl_rule" "private_inbound" {
  count = var.enable_nacls ? 1 : 0
  
  network_acl_id = aws_network_acl.private[0].id
  rule_number    = 100
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 0
  to_port        = 0
}

# NACL rule: Allow all outbound
resource "aws_network_acl_rule" "private_outbound" {
  count = var.enable_nacls ? 1 : 0
  
  network_acl_id = aws_network_acl.private[0].id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}
