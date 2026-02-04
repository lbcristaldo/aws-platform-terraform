variable "project_name" {
  description = "Name of the project (used as prefix for all resources)"
  type        = string
  default     = "aws-platform"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC (recommended /16 for clusters up to 50 nodes)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to use (2-3 recommended for HA)"
  type        = number
  default     = 3
  
  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "AZ count must be between 2 and 3 for high availability."
  }
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet internet access"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs for network traffic auditing"
  type        = bool
  default     = true
}

variable "enable_nacls" {
  description = "Enable Network ACLs for additional security layer"
  type        = bool
  default     = false
}

# IAM Configuration
variable "enable_ssm_access" {
  description = "Enable SSM access for EKS nodes (useful for debugging)"
  type        = bool
  default     = true
}

variable "enable_cluster_autoscaler" {
  description = "Enable Cluster Autoscaler IAM role"
  type        = bool
  default     = true
}

variable "enable_alb_controller" {
  description = "Enable ALB Controller for load balancing"
  type        = bool
  default     = true
}

# EKS Configuration
variable "kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.29"
  
  validation {
    condition     = can(regex("^1\\.([2-9][7-9]|[3-9][0-9])$", var.kubernetes_version))
    error_message = "Kubernetes version must be 1.27 or higher."
  }
}

variable "eks_endpoint_private_access" {
  description = "Enable private API server endpoint for EKS"
  type        = bool
  default     = true
}

variable "eks_endpoint_public_access" {
  description = "Enable public API server endpoint for EKS"
  type        = bool
  default     = true
}

variable "eks_public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "eks_enabled_cluster_log_types" {
  description = "List of control plane logging types to enable for EKS"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "eks_cluster_log_retention_days" {
  description = "Number of days to retain EKS cluster logs"
  type        = number
  default     = 30
}

# EKS Node Group Configuration
variable "eks_node_instance_types" {
  description = "List of instance types for EKS nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_capacity_type" {
  description = "Type of capacity for EKS nodes (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
  
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.eks_node_capacity_type)
    error_message = "Capacity type must be ON_DEMAND or SPOT."
  }
}

variable "eks_node_disk_size" {
  description = "Disk size in GB for EKS nodes"
  type        = number
  default     = 50
  
  validation {
    condition     = var.eks_node_disk_size >= 20
    error_message = "Node disk size must be at least 20 GB."
  }
}

variable "eks_node_min_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
  default     = 3
  
  validation {
    condition     = var.eks_node_min_size >= 1
    error_message = "Minimum node count must be at least 1."
  }
}

variable "eks_node_max_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 50
  
  validation {
    condition     = var.eks_node_max_size <= 100
    error_message = "Maximum node count cannot exceed 100."
  }
}

variable "eks_node_desired_size" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 3
  
  validation {
    condition     = var.eks_node_desired_size >= 1
    error_message = "Desired node count must be at least 1."
  }
}

variable "eks_node_labels" {
  description = "Key-value map of Kubernetes labels for EKS nodes"
  type        = map(string)
  default     = {}
}

# EKS Addon Versions
variable "eks_vpc_cni_version" {
  description = "Version of VPC CNI addon for EKS"
  type        = string
  default     = null  # Use latest
}

variable "eks_coredns_version" {
  description = "Version of CoreDNS addon for EKS"
  type        = string
  default     = null  # Use latest
}

variable "eks_kube_proxy_version" {
  description = "Version of kube-proxy addon for EKS"
  type        = string
  default     = null  # Use latest
}

variable "eks_ebs_csi_driver_version" {
  description = "Version of EBS CSI driver addon for EKS"
  type        = string
  default     = null  # Use latest
}

variable "eks_enable_cloudwatch_alarms" {
  description = "Enable CloudWatch alarms for EKS cluster monitoring"
  type        = bool
  default     = true
}

# RDS Configuration
variable "rds_engine_version" {
  description = "PostgreSQL engine version for RDS"
  type        = string
  default     = "16"
  
  validation {
    condition     = can(regex("^(13|14|15|16)$", var.rds_engine_version))
    error_message = "Engine version must be 13, 14, 15, or 16."
  }
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "rds_master_username" {
  description = "Master username for the RDS database"
  type        = string
  default     = "dbadmin"
  
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.rds_master_username))
    error_message = "Username must start with a letter and contain only alphanumeric characters and underscores."
  }
}

# RDS Storage Configuration
variable "rds_allocated_storage" {
  description = "Initial storage allocation in GB for RDS"
  type        = number
  default     = 100
  
  validation {
    condition     = var.rds_allocated_storage >= 20
    error_message = "Allocated storage must be at least 20 GB."
  }
}

variable "rds_max_allocated_storage" {
  description = "Maximum storage allocation for autoscaling in GB for RDS"
  type        = number
  default     = 500
  
  validation {
    condition     = var.rds_max_allocated_storage >= 100
    error_message = "Max allocated storage must be greater than or equal to allocated storage."
  }
}

variable "rds_iops" {
  description = "IOPS for gp3 storage for RDS (3000-16000)"
  type        = number
  default     = 3000
  
  validation {
    condition     = var.rds_iops >= 3000 && var.rds_iops <= 16000
    error_message = "IOPS must be between 3000 and 16000."
  }
}

variable "rds_storage_throughput" {
  description = "Storage throughput in MB/s for gp3 for RDS (125-1000)"
  type        = number
  default     = 125
  
  validation {
    condition     = var.rds_storage_throughput >= 125 && var.rds_storage_throughput <= 1000
    error_message = "Storage throughput must be between 125 and 1000 MB/s."
  }
}

variable "rds_multi_az" {
  description = "Enable multi-AZ deployment for RDS high availability"
  type        = bool
  default     = true
}

# RDS Backup Configuration
variable "rds_backup_retention_period" {
  description = "Number of days to retain automated backups for RDS (0-35)"
  type        = number
  default     = 7
  
  validation {
    condition     = var.rds_backup_retention_period >= 0 && var.rds_backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

variable "rds_backup_window" {
  description = "Preferred backup window (UTC) for RDS"
  type        = string
  default     = "03:00-04:00"
  
  validation {
    condition     = can(regex("^([0-1][0-9]|2[0-3]):[0-5][0-9]-([0-1][0-9]|2[0-3]):[0-5][0-9]$", var.rds_backup_window))
    error_message = "Backup window must be in format HH:MM-HH:MM."
  }
}

variable "rds_maintenance_window" {
  description = "Preferred maintenance window for RDS"
  type        = string
  default     = "sun:04:00-sun:05:00"
  
  validation {
    condition     = can(regex("^(mon|tue|wed|thu|fri|sat|sun):[0-2][0-9]:[0-5][0-9]-(mon|tue|wed|thu|fri|sat|sun):[0-2][0-9]:[0-5][0-9]$", var.rds_maintenance_window))
    error_message = "Maintenance window must be in format ddd:HH:MM-ddd:HH:MM."
  }
}

variable "rds_skip_final_snapshot" {
  description = "Skip final snapshot when deleting RDS database (not recommended for production)"
  type        = bool
  default     = false
}

# RDS Monitoring Configuration
variable "rds_monitoring_interval" {
  description = "Enhanced monitoring interval in seconds for RDS (0, 1, 5, 10, 15, 30, 60)"
  type        = number
  default     = 60
  
  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.rds_monitoring_interval)
    error_message = "Monitoring interval must be 0, 1, 5, 10, 15, 30, or 60 seconds."
  }
}

variable "rds_enable_performance_insights" {
  description = "Enable Performance Insights for RDS"
  type        = bool
  default     = true
}

variable "rds_performance_insights_retention" {
  description = "Performance Insights retention period in days for RDS (7 or 731)"
  type        = number
  default     = 7
  
  validation {
    condition     = contains([7, 731], var.rds_performance_insights_retention)
    error_message = "Performance Insights retention must be 7 or 731 days."
  }
}

variable "rds_enable_cloudwatch_alarms" {
  description = "Enable CloudWatch alarms for RDS monitoring"
  type        = bool
  default     = true
}

variable "rds_connection_alarm_threshold" {
  description = "Threshold for database connections alarm for RDS"
  type        = number
  default     = 80
}

# RDS Secrets Manager Rotation
variable "rds_enable_secret_rotation" {
  description = "Enable automatic rotation of master password for RDS"
  type        = bool
  default     = false
}

variable "rds_rotation_lambda_arn" {
  description = "ARN of Lambda function for secret rotation for RDS"
  type        = string
  default     = ""
}

variable "rds_rotation_days" {
  description = "Number of days between automatic secret rotations for RDS"
  type        = number
  default     = 30
  
  validation {
    condition     = var.rds_rotation_days >= 1 && var.rds_rotation_days <= 365
    error_message = "Rotation days must be between 1 and 365."
  }
}

# RDS Security
variable "rds_deletion_protection" {
  description = "Enable deletion protection for RDS"
  type        = bool
  default     = true
}

variable "rds_auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades for RDS"
  type        = bool
  default     = true
}

# Tags
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "aws-platform"
    Environment = "prod"
    ManagedBy   = "terraform"
    Owner       = "platform-team"
    CostCenter  = "engineering"
  }
}

# EKS Configuration

variable "endpoint_private_access" {
  type    = bool
  default = true
}

variable "endpoint_public_access" {
  type    = bool
  default = true
}

variable "public_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "enabled_cluster_log_types" {
  type    = list(string)
  default = ["api", "audit", "authenticator"]
}

variable "cluster_log_retention_days" {
  type    = number
  default = 30
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "node_capacity_type" {
  type    = string
  default = "ON_DEMAND"
}

variable "node_disk_size" {
  type    = number
  default = 50
}

variable "node_min_size" {
  type    = number
  default = 3
}

variable "node_max_size" {
  type    = number
  default = 50
}

variable "node_desired_size" {
  type    = number
  default = 3
}

variable "enable_cloudwatch_alarms" {
  type    = bool
  default = true
}

variable "rds_database_name" {
  type    = string
  default = "appdb"
}
