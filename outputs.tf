output "vpc_id"          { value = module.vpc.vpc_id }
output "eks_cluster"     { value = try(module.eks.cluster_name, "N/A") }
output "eks_endpoint"    { value = try(module.eks.cluster_endpoint, "N/A") }
output "rds_endpoint"    { value = try(module.db.db_instance_endpoint, "N/A") }