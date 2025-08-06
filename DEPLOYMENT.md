# Deployment Guide

This guide will help you deploy the KnowledgeCity infrastructure on AWS using Terraform.

## Prerequisites

1. **AWS CLI** - Install from [AWS CLI Documentation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
2. **Terraform** - Install from [Terraform Downloads](https://developer.hashicorp.com/terraform/downloads)
3. **AWS Account** with appropriate permissions
4. **Domain Name** (e.g., knowledgecity.com) - You'll need to own this domain

## AWS Permissions Required

Your AWS user/role needs the following permissions:
- EC2 (for VPC, ALB, EKS)
- RDS
- S3
- CloudFront
- Route53
- IAM
- CloudWatch
- WAF
- KMS
- EKS
- ClickHouse

## Quick Setup

### Option 1: Automated Setup (Recommended)

```bash
# Run the setup script
./setup-aws.sh
```

This script will:
- Check for required tools
- Configure AWS credentials
- Test credentials
- Initialize Terraform
- Run terraform plan

### Option 2: Manual Setup

1. **Configure AWS Credentials**
   ```bash
   aws configure
   ```

2. **Create terraform.tfvars file**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your specific values
   ```

3. **Initialize Terraform**
   ```bash
   terraform init
   ```

4. **Plan the deployment**
   ```bash
   terraform plan
   ```

## Configuration

### Required Variables

Edit `terraform.tfvars` with your specific values:

```hcl
# Environment Configuration
environment = "prod"

# Domain Configuration
domain_name = "your-domain.com"  # Replace with your actual domain

# AWS Regions
primary_region = "us-east-1"      # US region
secondary_region = "me-south-1"   # Saudi Arabia region

# Database Configuration
database_instance_class = "db.r6g.xlarge"
database_engine_version = "8.0.35"
database_allocated_storage = 100

# ClickHouse Configuration
clickhouse_instance_type = "r6g.2xlarge"
clickhouse_node_count = 3
```

### Domain Setup

1. **Register your domain** (if not already done)
2. **Create a Route53 hosted zone** for your domain
3. **Update your domain's nameservers** to point to Route53

## Deployment Steps

### 1. Pre-deployment Checks

```bash
# Verify AWS credentials
aws sts get-caller-identity

# Check Terraform version
terraform version

# Validate Terraform configuration
terraform validate
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Plan Deployment

```bash
terraform plan
```

Review the plan carefully to ensure it matches your expectations.

### 4. Deploy Infrastructure

```bash
terraform apply
```

When prompted, type `yes` to confirm the deployment.

### 5. Post-deployment Setup

After successful deployment:

1. **Configure DNS**: Update your domain's nameservers to use the Route53 nameservers
2. **SSL Certificates**: The ALB will automatically request SSL certificates
3. **Application Deployment**: Deploy your applications to the EKS clusters

## Architecture Overview

The deployment creates:

- **Multi-region setup**: US (primary) and Saudi Arabia (secondary)
- **VPCs**: Isolated networks in each region
- **EKS Clusters**: Kubernetes clusters for application deployment
- **RDS Databases**: MySQL databases with read replicas
- **ClickHouse**: Analytics database
- **S3 Buckets**: Global content and video storage
- **CloudFront**: Global CDN for content delivery
- **ALBs**: Application load balancers with SSL
- **Route53**: Global DNS with health checks and failover
- **Monitoring**: CloudWatch, Prometheus, Grafana
- **Security**: WAF, security groups, KMS encryption

## Troubleshooting

### Common Issues

1. **AWS Credentials Error**
   ```
   Error: InvalidClientTokenId: The security token included in the request is invalid
   ```
   **Solution**: Run `./setup-aws.sh` or configure AWS credentials manually

2. **Target Group Name Too Long**
   ```
   Error: "name" cannot be longer than 32 characters
   ```
   **Solution**: Fixed in the code - target group names are now truncated

3. **Route53 Zone ID Empty**
   ```
   Error: zone_id must not be empty
   ```
   **Solution**: Fixed in the code - certificate validation is now conditional

4. **RDS Read Replica Error**
   ```
   Error: "replicate_source_db" must be an ARN when "db_subnet_group_name" is set
   ```
   **Solution**: Fixed in the code - now uses ARN instead of identifier

### Getting Help

1. **Check Terraform logs**: `terraform plan -detailed-exitcode`
2. **Check AWS CloudTrail**: For API call errors
3. **Review CloudWatch logs**: For application-level issues

## Cost Estimation

Estimated monthly costs (varies by region and usage):

- **EKS Clusters**: $150-300/month
- **RDS Databases**: $200-500/month
- **ClickHouse**: $300-600/month
- **S3 Storage**: $0.023/GB/month
- **CloudFront**: $0.085/GB transfer
- **ALB**: $16/month per load balancer
- **Route53**: $0.50/month per hosted zone

**Total estimated cost**: $800-1500/month

## Security Considerations

1. **Database Passwords**: Change default passwords in production
2. **Access Keys**: Use IAM roles instead of access keys when possible
3. **Network Security**: Review security group rules
4. **Encryption**: All data is encrypted at rest and in transit
5. **WAF**: Web Application Firewall is enabled by default

## Maintenance

### Regular Tasks

1. **Terraform Updates**: Run `terraform plan` monthly to check for updates
2. **Security Patches**: Keep Terraform and provider versions updated
3. **Cost Monitoring**: Monitor AWS costs in CloudWatch
4. **Backup Verification**: Test RDS backups regularly

### Scaling

- **EKS**: Modify node group configurations in `terraform.tfvars`
- **RDS**: Adjust instance class and storage
- **ClickHouse**: Change node count and instance types

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

**Warning**: This will delete all resources and data. Make sure to backup any important data first.

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review AWS documentation
3. Check Terraform documentation
4. Review the architecture documentation in `ARCHITECTURE.md` 