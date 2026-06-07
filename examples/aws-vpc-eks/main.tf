# Option: AWS + VPC + EKS + Remote State
terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.50" }
  }
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/vpc-eks.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
  default_tags { tags = { Environment = var.environment, ManagedBy = "Terraform" } }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8"
  name    = "${var.project}-vpc"
  cidr    = var.vpc_cidr
  azs             = ["${var.aws_region}a","${var.aws_region}b","${var.aws_region}c"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = var.environment != "prod"
  enable_dns_hostnames = true
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  cluster_name    = "${var.project}-eks"
  cluster_version = "1.30"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  eks_managed_node_groups = {
    general = {
      instance_types = [var.node_instance_type]
      min_size = 2 ; max_size = 10 ; desired_size = 3
    }
  }
}