data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

output "subnet_id" {
  value = data.aws_subnets.selected.ids
}

data "aws_security_groups" "test" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

output "security_groups" {
  value = data.aws_security_groups.test.ids
}