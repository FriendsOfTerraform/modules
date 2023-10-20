locals {
  common_tags = {
    managed-by = "Terraform"
  }
}

data "aws_subnet" "subnet" {
  id = var.subnet_id
}