#!/bin/bash

# KnowledgeCity Platform - Terraform Deployment Script
# This script automates the deployment of the KnowledgeCity infrastructure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform >= 1.0"
        exit 1
    fi
    
    # Check Terraform version
    TF_VERSION=$(terraform version -json | jq -r '.terraform_version')
    print_status "Terraform version: $TF_VERSION"
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install AWS CLI"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials are not configured. Please run 'aws configure'"
        exit 1
    fi
    
    # Check if terraform.tfvars exists
    if [ ! -f "terraform.tfvars" ]; then
        print_warning "terraform.tfvars not found. Creating from example..."
        if [ -f "terraform.tfvars.example" ]; then
            cp terraform.tfvars.example terraform.tfvars
            print_warning "Please edit terraform.tfvars with your specific values before continuing"
            exit 1
        else
            print_error "terraform.tfvars.example not found"
            exit 1
        fi
    fi
    
    print_success "Prerequisites check completed"
}

# Function to validate configuration
validate_config() {
    print_status "Validating configuration..."
    
    # Validate terraform.tfvars
    if ! terraform validate; then
        print_error "Terraform configuration validation failed"
        exit 1
    fi
    
    print_success "Configuration validation completed"
}

# Function to initialize Terraform
init_terraform() {
    print_status "Initializing Terraform..."
    
    if ! terraform init; then
        print_error "Terraform initialization failed"
        exit 1
    fi
    
    print_success "Terraform initialization completed"
}

# Function to plan deployment
plan_deployment() {
    print_status "Planning deployment..."
    
    if ! terraform plan -out=tfplan; then
        print_error "Terraform plan failed"
        exit 1
    fi
    
    print_success "Deployment plan created"
}

# Function to apply deployment
apply_deployment() {
    print_status "Applying deployment..."
    
    if [ ! -f "tfplan" ]; then
        print_error "Deployment plan not found. Run 'terraform plan' first"
        exit 1
    fi
    
    if ! terraform apply tfplan; then
        print_error "Terraform apply failed"
        exit 1
    fi
    
    print_success "Deployment completed successfully"
}

# Function to show outputs
show_outputs() {
    print_status "Retrieving deployment outputs..."
    
    terraform output
}

# Function to cleanup
cleanup() {
    print_status "Cleaning up temporary files..."
    
    if [ -f "tfplan" ]; then
        rm tfplan
    fi
    
    print_success "Cleanup completed"
}

# Function to destroy infrastructure
destroy_infrastructure() {
    print_warning "This will destroy all infrastructure. Are you sure? (y/N)"
    read -r response
    
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_status "Destroying infrastructure..."
        
        if ! terraform destroy -auto-approve; then
            print_error "Infrastructure destruction failed"
            exit 1
        fi
        
        print_success "Infrastructure destroyed successfully"
    else
        print_status "Infrastructure destruction cancelled"
    fi
}

# Function to show help
show_help() {
    echo "KnowledgeCity Platform - Terraform Deployment Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  deploy      - Deploy the complete infrastructure"
    echo "  plan        - Create deployment plan only"
    echo "  apply       - Apply existing plan"
    echo "  destroy     - Destroy all infrastructure"
    echo "  validate    - Validate configuration"
    echo "  outputs     - Show deployment outputs"
    echo "  help        - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 deploy"
    echo "  $0 plan"
    echo "  $0 destroy"
}

# Main script logic
case "${1:-deploy}" in
    "deploy")
        check_prerequisites
        validate_config
        init_terraform
        plan_deployment
        apply_deployment
        show_outputs
        cleanup
        ;;
    "plan")
        check_prerequisites
        validate_config
        init_terraform
        plan_deployment
        ;;
    "apply")
        check_prerequisites
        apply_deployment
        show_outputs
        cleanup
        ;;
    "destroy")
        check_prerequisites
        init_terraform
        destroy_infrastructure
        ;;
    "validate")
        check_prerequisites
        validate_config
        ;;
    "outputs")
        show_outputs
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac 