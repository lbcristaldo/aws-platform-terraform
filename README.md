# AWS EKS Infrastructure as Code
---
## Overview

This Terraform project provides a production-ready infrastructure setup for AWS EKS (Elastic Kubernetes Service) with all necessary supporting components. It follows infrastructure-as-code best practices and implements security, high availability, and scalability principles.

---

## Architecture

The infrastructure is organized into modular Terraform configurations:

graph TB
    subgraph "AWS Infrastructure as Code"
        direction TB
        
        subgraph "Módulo VPC"
            VPC[aws_vpc.main]
            IGW[aws_internet_gateway.main]
            PubSub[aws_subnet.public]
            PrivSub[aws_subnet.private]
            NAT[aws_nat_gateway.main]
            RT[Route Tables]
            FL[VPC Flow Logs]
            
            VPC --> IGW
            VPC --> PubSub
            VPC --> PrivSub
            PubSub --> NAT
            NAT --> RT
            RT --> PrivSub
            VPC --> FL
        end
        
        subgraph "Módulo IAM-BASE"
            direction TB
            
            subgraph "EKS IAM Roles"
                EKSClusterRole[aws_iam_role.eks_cluster]
                EKSNodeRole[aws_iam_role.eks_nodes]
                ClusterPolicy[Cluster Policy Attachments]
                NodePolicy[Node Policy Attachments]
                SecretsPolicy[Secrets Manager Policy]
            end
            
            subgraph "IRSA IAM Roles"
                ClusterAutoscalerRole[aws_iam_role.cluster_autoscaler]
                ALBControllerRole[aws_iam_role.aws_load_balancer_controller]
                ClusterAutoscalerPolicy[Cluster Autoscaler Policy]
                ALBControllerPolicy[ALB Controller Policy]
            end
        end
        
        subgraph "Módulo Security"
            direction TB
            
            EKSControlPlaneSG[aws_security_group.eks_control_plane]
            EKSNodeSG[aws_security_group.eks_nodes]
            RDSSG[aws_security_group.rds]
            ALBSG[aws_security_group.alb]
            SGRules[Security Group Rules]
            NACL[Network ACLs - Opcional]
        end
        
        subgraph "Módulo RDS"
            direction TB
            
            KMSRDS[aws_kms_key.rds]
            DBSubnetGroup[aws_db_subnet_group.main]
            DBParamGroup[aws_db_parameter_group.main]
            RDSInstance[aws_db_instance.main]
            SecretsManager[aws_secretsmanager_secret.rds_master]
            MonitoringRole[aws_iam_role.rds_monitoring]
            CloudWatchAlarms[RDS CloudWatch Alarms]
            
            KMSRDS --> RDSInstance
            DBSubnetGroup --> RDSInstance
            DBParamGroup --> RDSInstance
            SecretsManager --> RDSInstance
            MonitoringRole --> RDSInstance
        end
        
        subgraph "Módulo EKS"
            direction TB
            
            KMSEKS[aws_kms_key.eks]
            EKSCluster[aws_eks_cluster.main]
            OIDCProvider[aws_iam_openid_connect_provider.eks]
            LaunchTemplate[aws_launch_template.eks_nodes]
            NodeGroup[aws_eks_node_group.main]
            EKSAddons[EKS Addons]
            CWLogs[CloudWatch Log Group]
            
            KMSEKS --> EKSCluster
            EKSCluster --> OIDCProvider
            LaunchTemplate --> NodeGroup
            EKSCluster --> NodeGroup
            EKSCluster --> EKSAddons
            EKSCluster --> CWLogs
        end
        
        %% Dependencias entre módulos
        VPC --> EKSControlPlaneSG
        VPC --> EKSNodeSG
        VPC --> RDSSG
        VPC --> ALBSG
        
        PrivSub --> DBSubnetGroup
        PrivSub --> NodeGroup
        
        EKSClusterRole --> EKSCluster
        EKSNodeRole --> NodeGroup
        
        EKSControlPlaneSG --> EKSCluster
        EKSNodeSG --> NodeGroup
        RDSSG --> RDSInstance
        
        OIDCProvider -.-> ClusterAutoscalerRole
        OIDCProvider -.-> ALBControllerRole
        
        %% Flujo de creación
        IAM-BASE --> Security
        VPC --> Security
        VPC --> RDS
        VPC --> EKS
        Security --> RDS
        Security --> EKS
        IAM-BASE --> EKS
    end
    
    subgraph "Outputs Destacados"
        EKSOutputs["EKS:<br/>• cluster_endpoint<br/>• oidc_provider_arn<br/>• node_group_id"]
        RDSOutputs["RDS:<br/>• db_instance_endpoint<br/>• secret_arn<br/>• kms_key_arn"]
        VPCOutputs["VPC:<br/>• vpc_id<br/>• private_subnet_ids<br/>• nat_gateway_ips"]
        IAMOutputs["IAM:<br/>• eks_nodes_role_arn<br/>• cluster_autoscaler_role_arn"]
        
        EKS --> EKSOutputs
        RDS --> RDSOutputs
        VPC --> VPCOutputs
        IAM-BASE --> IAMOutputs
    end
    
    subgraph "Variables Principales"
        CommonVars["project_name, tags"]
        NetworkVars["vpc_cidr, availability_zones"]
        EKSVars["cluster_name, kubernetes_version"]
        RDSVars["instance_class, engine_version"]
    end
    
    CommonVars -.-> VPC
    CommonVars -.-> IAM-BASE
    CommonVars -.-> Security
    CommonVars -.-> RDS
    CommonVars -.-> EKS
    
    NetworkVars --> VPC
    EKSVars --> EKS
    RDSVars --> RDS
    
    style VPC fill:#e1f5fe
    style IAM-BASE fill:#f3e5f5
    style Security fill:#fce4ec
    style RDS fill:#e8f5e8
    style EKS fill:#fff3e0
    style EKSOutputs fill:#bbdefb
    style RDSOutputs fill:#c8e6c9
    style VPCOutputs fill:#e1f5fe
    style IAMOutputs fill:#f3e5f5

---

## Detailed Infrastructure Dependencies

![Terraform Dependency Graph](./diagram.svg)

*Generated with `terraform graph | dot -Tsvg` - shows actual resource dependencies*

---

### Core Modules

1. **VPC Module** - Multi-AZ network infrastructure with public/private subnets, NAT Gateways, and VPC Flow Logs
2. **IAM Module** - IAM roles and policies for EKS cluster, worker nodes, and IRSA (IAM Roles for Service Accounts)
3. **Security Module** - Security Groups and Network ACLs implementing defense-in-depth security
4. **RDS Module** - PostgreSQL Multi-AZ database with encryption, backups, and monitoring
5. **EKS Module** - Managed Kubernetes cluster with node groups, OIDC provider, and essential addons

---

### Key Features

- **High Availability**: Multi-AZ deployment across all components
- **Security**: KMS encryption, least-privilege IAM roles, security groups, IMDSv2 enforcement
- **Observability**: CloudWatch Logs, Metrics, and Alarms for all services
- **Secret Management**: AWS Secrets Manager with automatic rotation
- **Auto-scaling**: Cluster Autoscaler and configurable node group scaling
- **Infrastructure as Code**: Version-controlled, reproducible deployments

---

## Prerequisites

- AWS Account with appropriate permissions
- Terraform 1.6.0 or higher
- AWS CLI configured with credentials
- kubectl (for Kubernetes operations)

---

## Deployment

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd <project-directory>
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```

3. **Review and customize variables**
   - Update `terraform.tfvars` with your configuration
   - Modify variables in each module as needed

4. **Plan the deployment**
   ```bash
   terraform plan -out=tfplan
   ```

5. **Apply the configuration**
   ```bash
   terraform apply tfplan
   ```
---

## Usage

### Accessing EKS Cluster
After deployment, configure kubectl:
```bash
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

### Database Connection
Retrieve database credentials from Secrets Manager:
```bash
aws secretsmanager get-secret-value --secret-id <secret-arn>
```

### Monitoring
Access CloudWatch dashboards for:
- EKS cluster metrics
- RDS performance insights
- VPC Flow Logs
- Application Load Balancer metrics

## Module Variables

Each module accepts standardized variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `project_name` | Prefix for all resources | Required |
| `tags` | Common tags for resources | `{}` |
| `environment` | Environment identifier | `production` |

## Outputs

Key outputs include:
- EKS cluster endpoint and OIDC provider ARN
- RDS connection endpoint and secret ARN
- VPC and subnet IDs
- IAM role ARNs for service accounts
- Security group IDs
- KMS key ARNs for encryption

---

## Security Considerations

- All data at rest is encrypted using AWS KMS
- IAM roles follow principle of least privilege
- Security groups restrict traffic to minimum required
- Secrets are managed via AWS Secrets Manager
- IMDSv2 is enforced on all EC2 instances

---

## Cost Estimation

The infrastructure includes:
- EKS cluster with 3 t3.medium nodes (on-demand)
- RDS PostgreSQL db.t3.medium Multi-AZ
- NAT Gateways (one per AZ)
- Standard CloudWatch Logs retention

Estimated monthly cost: ~$500-800 depending on region and usage.

---

## Future Enhancements

### Security Additions
- **Kyverno**: Kubernetes policy engine for enforcing security policies, validating resources, and mutating configurations
- **Falco**: Runtime security monitoring for Kubernetes
- **Kube-bench**: CIS benchmark compliance scanning
- **OPA/Gatekeeper**: Policy-based control for Kubernetes

### Observability
- **Prometheus/Grafana**: Advanced metrics collection and visualization
- **Loki**: Log aggregation system
- **Tempo**: Distributed tracing
- **OpenTelemetry**: Unified observability framework

### CI/CD Integration
- **ArgoCD**: GitOps continuous delivery
- **Tekton**: Cloud-native CI/CD pipelines

### Service Mesh
- **Linkerd**: Lightweight service mesh focused on simplicity and performance

-- Linkerd was chosen for its simplicity, performance, and low resource footprint. 
While Istio offers extensive features, Linkerd provides essential service mesh capabilities (automatic mTLS, traffic splitting, observability) with minimal operational overhead. 
Its lightweight proxy -~10MB vs Istio's 1.5GB- reduces infrastructure costs and simplifies troubleshooting.

### Storage Enhancements
- **EFS CSI Driver**: Persistent storage for shared filesystems
- **Rook/Ceph**: Cloud-native storage orchestration

### Backup and Disaster Recovery
- **Velero**: Kubernetes backup and migration tool
- **AWS Backup**: Centralized backup management

---

## Maintenance

### Updates
- Monitor AWS announcements for EKS and RDS version updates
- Regularly update Terraform providers and modules
- Review and rotate IAM credentials and KMS keys periodically

### Scaling
- Adjust node group sizes based on workload requirements
- Modify RDS instance class and storage as needed
- Review and update security groups as application requirements change

## Troubleshooting

Common issues and solutions:

1. **EKS nodes not joining cluster**: Check IAM role permissions and security group rules
2. **RDS connection failures**: Verify security group ingress rules and subnet connectivity
3. **Terraform state issues**: Use remote state backend (S3 + DynamoDB) for team collaboration

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and feature requests, please use the project's issue tracker.
