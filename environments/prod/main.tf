# Root Configuration - AWS Platform Infrastructure
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.common_tags
  }
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  cluster_name       = "${var.project_name}-eks-cluster"
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  availability_zones = local.availability_zones
  enable_nat_gateway = var.enable_nat_gateway
  enable_flow_logs   = var.enable_flow_logs

  tags = var.common_tags
}

# Security Module
module "security" {
  source = "../../modules/security"

  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = module.vpc.vpc_cidr
  cluster_name       = local.cluster_name
  private_subnet_ids = module.vpc.private_subnet_ids
  enable_nacls       = var.enable_nacls

  tags = var.common_tags

  depends_on = [module.vpc]
}

# IAM-BASE Module (without OIDC)
module "iam_base" {
  source = "../../modules/iam-base"
  
  project_name      = var.project_name
  aws_region        = var.aws_region
  aws_account_id    = data.aws_caller_identity.current.account_id
  enable_ssm_access = var.enable_ssm_access
  
  tags = var.common_tags
}

# EKS Module
module "eks" {
  source = "../../modules/eks"
  
  cluster_name              = local.cluster_name
  kubernetes_version        = var.kubernetes_version
  cluster_role_arn          = module.iam_base.eks_cluster_role_arn
  node_role_arn             = module.iam_base.eks_nodes_role_arn
  private_subnet_ids        = module.vpc.private_subnet_ids
  public_subnet_ids         = module.vpc.public_subnet_ids
  cluster_security_group_id = module.security.eks_control_plane_security_group_id
  node_security_group_id    = module.security.eks_nodes_security_group_id

  # Endpoint configuration
  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access
  public_access_cidrs     = var.public_access_cidrs

  # Logging
  enabled_cluster_log_types  = var.enabled_cluster_log_types
  cluster_log_retention_days = var.cluster_log_retention_days

  # Node configuration
  node_instance_types = var.node_instance_types
  node_capacity_type  = var.node_capacity_type
  node_disk_size      = var.node_disk_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_desired_size   = var.node_desired_size

  # Monitoring
  enable_cloudwatch_alarms = var.enable_cloudwatch_alarms

  tags = var.common_tags
  
  depends_on = [
    module.vpc,
    module.security,
    module.iam_base
  ]
}

# IAM-IRSA Module (with  OIDC - EKS dependency)
module "iam_irsa" {
  source = "../../modules/iam-irsa"
  
  project_name              = var.project_name
  oidc_provider_arn         = module.eks.oidc_provider_arn
  oidc_provider             = module.eks.oidc_provider
  enable_cluster_autoscaler = var.enable_cluster_autoscaler
  enable_alb_controller     = var.enable_alb_controller
  
  tags = var.common_tags
  
  depends_on = [module.eks]
}

# Attach KMS policy to node role after EKS is created
resource "aws_iam_policy" "eks_kms" {
  name        = "${var.project_name}-eks-nodes-kms-policy"
  description = "Allow EKS nodes to use KMS key from EKS module"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "kms:Decrypt",
        "kms:DescribeKey"
      ]
      Resource = module.eks.kms_key_arn
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_nodes_kms" {
  policy_arn = aws_iam_policy.eks_kms.arn
  role       = module.iam_base.eks_nodes_role_name
}

# RDS Module
module "rds" {
  source = "../../modules/rds"

  project_name          = var.project_name
  private_subnet_ids    = module.vpc.private_subnet_ids
  rds_security_group_id = module.security.rds_security_group_id

  engine_version  = var.rds_engine_version
  instance_class  = var.rds_instance_class
  database_name   = var.rds_database_name
  master_username = var.rds_master_username

  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage

  multi_az = var.rds_multi_az

  backup_retention_period = var.rds_backup_retention_period
  skip_final_snapshot     = var.rds_skip_final_snapshot

  monitoring_interval         = var.rds_monitoring_interval
  enable_performance_insights = var.rds_enable_performance_insights
  enable_cloudwatch_alarms    = var.enable_cloudwatch_alarms

  deletion_protection = var.rds_deletion_protection

  tags = var.common_tags

  depends_on = [module.vpc, module.security]
}
