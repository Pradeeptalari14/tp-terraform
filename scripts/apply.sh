#!/usr/bin/env bash
set -euo pipefail
ENV="${1:-staging}"
echo "Terraform apply for: $ENV"
terraform init -reconfigure
terraform workspace select "$ENV" 2>/dev/null || terraform workspace new "$ENV"
terraform plan -out=tfplan -var="environment=$ENV"
echo "Review the plan above. Press ENTER to apply or Ctrl+C to cancel."
read -r
terraform apply tfplan
echo "Done: $ENV"