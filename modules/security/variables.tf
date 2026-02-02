variable "project_name" {
  description = "Name prefix for all resources"
  type = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC for NACL rules"
  type = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for NACL association"
  type = list(string)
  default = []
}

variable "enable_nacls" {
  description = "Enable Network ACLs for additional security layer"
  type = bool
  default = false
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type = map(string)
  default = {}
}
