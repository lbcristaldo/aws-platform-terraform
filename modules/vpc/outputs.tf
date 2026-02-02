output "vpc_id" {
  description = "The ID of the VPC"
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets (for load balancers)"
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets (for EKS nodes and RDS)"
  value = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "List of CIDR blocks of public subnets"
  value = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks of private subnets"
  value = aws_subnet.private[*].cidr_block
}

output "nat_gateway_ips" {
  description = "List of Elastic IP addresses of NAT Gateways"
  value = var.enable_nat_gateway ? aws_eip.nat[*].public_ip : []
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value = aws_internet_gateway.main.id
}

output "availability_zones" {
  description = "List of availability zones used"
  value = var.availability_zones
}
