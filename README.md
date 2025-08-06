# KnowledgeCity Platform - Terraform Infrastructure
https://lucid.app/lucidchart/2efd8c7a-1787-4132-8f9c-2151dec99f47/edit?viewport_loc=-5504%2C-1584%2C6388%2C3772%2C0_0&invitationId=inv_8e0d77d2-a8f8-4bb1-8726-4f273b246441


[![Terraform](https://img.shields.io/badge/Terraform-v1.0%2B-blue?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-orange?logo=amazon-aws)](https://aws.amazon.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> **Enterprise-grade, multi-region, highly available infrastructure for the KnowledgeCity educational platform, managed with Terraform.**

---

## Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Scaling & Cost Optimization](#scaling--cost-optimization)
- [Security & Compliance](#security--compliance)
- [Monitoring & Maintenance](#monitoring--maintenance)
- [Disaster Recovery](#disaster-recovery)
- [Troubleshooting & FAQ](#troubleshooting--faq)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## Overview
KnowledgeCity Platform leverages Terraform to provision and manage a robust, secure, and scalable AWS infrastructure for a global educational service. The platform is designed for high availability, regional data compliance, and cost efficiency.

## Architecture
- **Multi-Region:** US-East-1 (primary), ME-South-1 (secondary)
- **Core Components:**
  - Frontend SPA (React/Svelte) via CloudFront CDN
  - Monolithic PHP backend, analytics (ClickHouse), video processing microservices
  - RDS MySQL, S3 Buckets, EKS clusters, ALB, Route53
- **Security:** WAF, AWS Shield, GuardDuty, KMS, IAM, Security Groups
- **Monitoring:** CloudWatch, Prometheus, Grafana

**See detailed diagrams:**
- [AWS Architecture Diagram (with icons)](aws-architecture-diagram-with-icons.md)
- [Component Diagram](component-diagram.md)
- [Network Topology](network-topology.md)

## Features
- Multi-region, highly available setup
- Regional data compliance (US & Saudi Arabia)
- Modular Terraform codebase
- Automated monitoring, alerting, and disaster recovery
- Cost optimization strategies
- Secure by design (encryption, IAM, WAF, DDoS protection)

## Getting Started
### Prerequisites
- Terraform >= 1.0
- AWS CLI configured with credentials
- Registered domain in Route53
- Sufficient AWS permissions

### Quick Start
```bash
# 1. Clone the repository
 git clone <repository-url>
 cd Devops-task

# 2. Configure variables
 cp terraform.tfvars.example terraform.tfvars
 # Edit terraform.tfvars with your values

# 3. Initialize Terraform
 terraform init

# 4. Plan and apply
 terraform plan
 terraform apply
```

## Configuration
Edit `terraform.tfvars` to customize your deployment. Example variables:
```hcl
# Environment
environment = "prod"
# Domain
domain_name = "knowledgecity.com"
# Regions
primary_region = "us-east-1"
secondary_region = "me-south-1"
# EKS Node Groups, RDS, ClickHouse, S3, Security, Monitoring, Tags, etc.
```
See [`terraform.tfvars.example`](terraform.tfvars.example) for all options and documentation.

## Deployment
- Modular structure under `modules/` for VPC, EKS, RDS, ClickHouse, S3, CloudFront, ALB, Route53, Monitoring, Security
- Follows phased deployment: Foundation → Core Infra → Global Distribution → Monitoring/Security
- See [DEPLOYMENT.md](DEPLOYMENT.md) for advanced deployment scenarios and blue/green updates

## Scaling & Cost Optimization
- **Horizontal scaling:** EKS auto-scaling, ALB target groups, CloudFront edge
- **Vertical scaling:** RDS, EKS node groups, S3 auto-scaling
- **Cost controls:** Reserved/Spot Instances, S3 lifecycle, CloudFront, multi-AZ only where needed
- See [cost-optimization-smallest-resources.md](cost-optimization-smallest-resources.md)

## Security & Compliance
- Encryption at rest/in transit (KMS)
- IAM least privilege, audit logging
- WAF, AWS Shield, GuardDuty
- Regional data compliance (US/EU/ME)
- See [deployment-architecture.md](deployment-architecture.md) for compliance details

## Monitoring & Maintenance
- CloudWatch, Prometheus, Grafana dashboards
- Route53 health checks, custom alarms
- Regular patching, backup verification, cost reviews
- See [monitoring/main.tf](modules/monitoring/main.tf) and [prometheus.yml](modules/monitoring/prometheus.yml)

## Disaster Recovery
- Multi-region failover, cross-region replication
- Automated backups, documented RTO/RPO
- See [network-architecture-detailed.md](network-architecture-detailed.md)

## Troubleshooting & FAQ
**Common Issues:**
- Certificate validation: Check domain config
- Cross-region: Verify provider blocks
- IAM: Ensure correct permissions
- VPC peering: Check routing

**Support:**
- CloudWatch logs for app issues
- WAF logs for security
- Route53 health checks for availability

## Contributing
1. Fork the repo
2. Create a feature branch
3. Make changes & test
4. Submit a pull request

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact
For questions or support, contact the DevOps team at [devops@knowledgecity.com](mailto:devops@knowledgecity.com) 
