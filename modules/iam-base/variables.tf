variable "project_name" {
  description = "Name prefix for all IAM resources"
  type        = string
}

variable "aws_region" {
  description = "AWS region for resource ARNs"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID for resource ARNs"
  type        = string
}

variable "enable_ssm_access" {
  description = "Enable SSM access for EKS nodes"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
