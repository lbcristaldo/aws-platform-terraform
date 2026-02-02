variable "project_name" {
  description = "Name prefix for all resources in this module"
  type = string
  
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC. Recommended /16 for clusters up to 50 nodes"
  type = string
  default = "10.0.0.0/16"
  
  validation {
    condition = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones for multi-AZ deployment (minimum 2, recommended 3)"
  type = list(string)
  
  validation {
    condition = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones are required for high availability."
  }
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet internet access (required for EKS nodes)"
  type = bool
  default = true
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs for network traffic auditing"
  type = bool
  default = true
}

variable "flow_logs_retention_days" {
  description = "Number of days to retain VPC Flow Logs in CloudWatch"
  type = number
  default = 30
  
  validation {
    condition = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.flow_logs_retention_days)
    error_message = "Flow logs retention must be a valid CloudWatch Logs retention period."
  }
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type = map(string)
  default = {}
}
