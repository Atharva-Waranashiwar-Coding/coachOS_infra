resource "aws_cloudwatch_log_group" "coachos" {
  name              = "/${var.name}/coachos"
  retention_in_days = 30
}
