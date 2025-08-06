#!/bin/bash

# Setup script for AWS credentials and Terraform deployment
echo "Setting up AWS credentials and environment..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it first."
    echo "Visit: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "Terraform is not installed. Please install it first."
    echo "Visit: https://developer.hashicorp.com/terraform/downloads"
    exit 1
fi

# Configure AWS credentials
echo "Configuring AWS credentials..."
echo "Please enter your AWS Access Key ID:"
read -s AWS_ACCESS_KEY_ID
echo "Please enter your AWS Secret Access Key:"
read -s AWS_SECRET_ACCESS_KEY
echo "Please enter your AWS region (default: us-east-1):"
read AWS_DEFAULT_REGION
AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-1}

# Set AWS credentials
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION

# Configure AWS CLI
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set default.region "$AWS_DEFAULT_REGION"

# Test AWS credentials
echo "Testing AWS credentials..."
if aws sts get-caller-identity &> /dev/null; then
    echo "✅ AWS credentials are valid!"
    aws sts get-caller-identity
else
    echo "❌ AWS credentials are invalid. Please check your credentials."
    exit 1
fi

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Plan Terraform deployment
echo "Planning Terraform deployment..."
terraform plan

echo "Setup complete! You can now run 'terraform apply' to deploy the infrastructure." 