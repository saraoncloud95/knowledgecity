terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

# Configure AWS Provider for multiple regions
provider "aws" {
  region = var.primary_region
  alias  = "primary"
}

provider "aws" {
  region = var.secondary_region
  alias  = "secondary"
}

# Local variables for common tags
locals {
  common_tags = {
    Project     = "KnowledgeCity"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "DevOps"
  }
}

# VPC and Networking for Primary Region (US)
module "vpc_primary" {
  source = "./modules/vpc"
  
  providers = {
    aws = aws.primary
  }
  
  region             = var.primary_region
  vpc_cidr           = var.primary_vpc_cidr
  environment        = var.environment
  availability_zones = var.primary_availability_zones
  common_tags        = local.common_tags
}

# VPC and Networking for Secondary Region (Saudi Arabia)
module "vpc_secondary" {
  source = "./modules/vpc"
  
  providers = {
    aws = aws.secondary
  }
  
  region             = var.secondary_region
  vpc_cidr           = var.secondary_vpc_cidr
  environment        = var.environment
  availability_zones = var.secondary_availability_zones
  common_tags        = local.common_tags
}

# EKS Cluster for Primary Region
module "eks_primary" {
  source = "./modules/eks"
  
  providers = {
    aws = aws.primary
  }
  
  cluster_name       = "${var.environment}-eks-primary"
  region             = var.primary_region
  vpc_id             = module.vpc_primary.vpc_id
  subnet_ids         = module.vpc_primary.private_subnet_ids
  node_groups        = var.primary_node_groups
  common_tags        = local.common_tags
}

# EKS Cluster for Secondary Region
module "eks_secondary" {
  source = "./modules/eks"
  
  providers = {
    aws = aws.secondary
  }
  
  cluster_name       = "${var.environment}-eks-secondary"
  region             = var.secondary_region
  vpc_id             = module.vpc_secondary.vpc_id
  subnet_ids         = module.vpc_secondary.private_subnet_ids
  node_groups        = var.secondary_node_groups
  common_tags        = local.common_tags
}

# RDS Database for Primary Region (US Users)
module "rds_primary" {
  source = "./modules/rds"
  
  providers = {
    aws = aws.primary
  }
  
  identifier         = "${var.environment}-rds-primary"
  region             = var.primary_region
  vpc_id             = module.vpc_primary.vpc_id
  subnet_ids         = module.vpc_primary.database_subnet_ids
  security_group_ids = [module.vpc_primary.database_security_group_id]
  instance_class     = var.database_instance_class
  engine_version     = var.database_engine_version
  allocated_storage  = var.database_allocated_storage
  backup_retention_period = var.database_backup_retention_period
  common_tags        = local.common_tags
}

# RDS Database for Secondary Region (Saudi Arabia Users)
module "rds_secondary" {
  source = "./modules/rds"
  
  providers = {
    aws = aws.secondary
  }
  
  identifier         = "${var.environment}-rds-secondary"
  region             = var.secondary_region
  vpc_id             = module.vpc_secondary.vpc_id
  subnet_ids         = module.vpc_secondary.database_subnet_ids
  security_group_ids = [module.vpc_secondary.database_security_group_id]
  instance_class     = var.database_instance_class
  engine_version     = var.database_engine_version
  allocated_storage  = var.database_allocated_storage
  backup_retention_period = var.database_backup_retention_period
  common_tags        = local.common_tags
}

# ClickHouse Analytics Database
module "clickhouse" {
  source = "./modules/clickhouse"
  
  providers = {
    aws = aws.primary
  }
  
  cluster_name       = "${var.environment}-clickhouse"
  region             = var.primary_region
  subnet_ids         = module.vpc_primary.private_subnet_ids
  security_group_ids = [module.vpc_primary.database_security_group_id]
  task_cpu           = 256
  task_memory        = 512
  service_desired_count = var.clickhouse_node_count
  common_tags        = local.common_tags
}

# S3 Buckets for Global Content and Video Storage
module "storage" {
  source = "./modules/storage"
  
  providers = {
    aws.primary   = aws.primary
    aws.secondary = aws.secondary
  }
  
  environment        = var.environment
  primary_region     = var.primary_region
  secondary_region   = var.secondary_region
  common_tags        = local.common_tags
}

# CloudFront CDN for Global Content Delivery
module "cloudfront" {
  source = "./modules/cloudfront"
  
  providers = {
    aws = aws.primary
  }
  
  environment        = var.environment
  s3_bucket_domain  = module.storage.global_content_bucket_domain
  common_tags        = local.common_tags
}

# Application Load Balancers
module "alb_primary" {
  source = "./modules/alb"
  
  providers = {
    aws = aws.primary
  }
  
  name               = "${var.environment}-alb-primary"
  vpc_id             = module.vpc_primary.vpc_id
  subnet_ids         = module.vpc_primary.public_subnet_ids
  security_group_ids = [module.vpc_primary.alb_security_group_id]
  domain_name        = var.domain_name
  route53_zone_id    = ""
  common_tags        = local.common_tags
}

module "alb_secondary" {
  source = "./modules/alb"
  
  providers = {
    aws = aws.secondary
  }
  
  name               = "${var.environment}-alb-secondary"
  vpc_id             = module.vpc_secondary.vpc_id
  subnet_ids         = module.vpc_secondary.public_subnet_ids
  security_group_ids = [module.vpc_secondary.alb_security_group_id]
  domain_name        = var.domain_name
  route53_zone_id    = ""
  common_tags        = local.common_tags
}

# Route53 for Global DNS and Health Checks
module "route53" {
  source = "./modules/route53"
  
  providers = {
    aws = aws.primary
  }
  
  domain_name        = var.domain_name
  primary_alb_dns    = module.alb_primary.alb_dns_name
  secondary_alb_dns  = module.alb_secondary.alb_dns_name
  primary_alb_zone_id = module.alb_primary.alb_zone_id
  secondary_alb_zone_id = module.alb_secondary.alb_zone_id
  cloudfront_domain_name = module.cloudfront.domain_name
  primary_region     = var.primary_region
  secondary_region   = var.secondary_region
  common_tags        = local.common_tags
}

# Monitoring and Observability Stack
module "monitoring" {
  source = "./modules/monitoring"
  
  providers = {
    aws = aws.primary
  }
  
  environment        = var.environment
  primary_region     = var.primary_region
  secondary_region   = var.secondary_region
  subnet_ids         = module.vpc_primary.private_subnet_ids
  security_group_ids = [module.vpc_primary.application_security_group_id]
  common_tags        = local.common_tags
}

# Security and WAF
module "security" {
  source = "./modules/security"
  
  providers = {
    aws = aws.primary
  }
  
  environment        = var.environment
  domain_name        = var.domain_name
  alb_arn            = module.alb_primary.alb_arn
  primary_region     = var.primary_region
  common_tags        = local.common_tags
} 