# Option: AWS + VPC + RDS PostgreSQL
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8"
  name = "${var.project}-vpc"
  cidr = "10.0.0.0/16"
  azs             = ["us-east-1a","us-east-1b"]
  private_subnets = ["10.0.1.0/24","10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24","10.0.102.0/24"]
  enable_nat_gateway = true
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"
  identifier = "${var.project}-db"
  engine              = "postgres"
  engine_version      = "16.2"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  db_name  = "appdb"
  username = "admin"
  port     = 5432
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  skip_final_snapshot    = var.environment != "prod"
}