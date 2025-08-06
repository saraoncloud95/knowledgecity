# 🌍 KnowledgeCity Multi-Region AWS Architecture

<img width="6540" height="3440" alt="Blank diagram (4)" src="https://github.com/user-attachments/assets/8fb1efd1-08df-46aa-aadc-ad37ad65e24c" />


[![Terraform](https://img.shields.io/badge/Terraform-v1.0%2B-blue?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-orange?logo=amazon-aws)](https://aws.amazon.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> **Enterprise-grade, multi-region, highly available AWS infrastructure for the KnowledgeCity educational platform, managed with Terraform.**

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Module Structure](#module-structure)
- [Deployment](#deployment)
- [Multi-Region Support](#multi-region-support)
- [Scaling & Cost Optimization](#scaling--cost-optimization)
- [Security & Compliance](#security--compliance)
- [Monitoring & Maintenance](#monitoring--maintenance)
- [Disaster Recovery](#disaster-recovery)
- [CI/CD Pipeline](#cicd-pipeline)
- [Troubleshooting & FAQ](#troubleshooting--faq)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## Overview

KnowledgeCity leverages Terraform to provision and manage a robust, secure, and scalable AWS infrastructure for a global educational platform. The architecture is designed for high availability, regional data compliance, and cost efficiency.

---

## Architecture

- **Multi-Region:**  
  - **Primary:** us-east-1 (USA)  
  - **Secondary:** me-south-1 (Saudi Arabia)  
- **Core Components:**  
  - Frontend SPA (React/Svelte) via CloudFront CDN  
  - Monolithic PHP backend, analytics (ClickHouse), video processing microservices  
  - RDS MySQL, S3 Buckets, EKS clusters, ALB, Route53  
- **Security:** WAF, AWS Shield, GuardDuty, KMS, IAM, Security Groups  
- **Monitoring:** CloudWatch, Prometheus, Grafana


---

## Features

- Multi-region, highly available setup
- Regional data compliance (US & Saudi Arabia)
- Modular Terraform codebase
- Automated monitoring, alerting, and disaster recovery
- Cost optimization strategies
- Secure by design (encryption, IAM, WAF, DDoS protection)

---

## Getting Started

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured with credentials
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

---

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

---

## Module Structure
