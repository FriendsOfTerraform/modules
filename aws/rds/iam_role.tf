resource "aws_iam_role" "rds_enhanced_monitoring" {
  count = var.monitoring_config != null ? (
    var.monitoring_config.enable_enhanced_monitoring != null ? (
      var.monitoring_config.enable_enhanced_monitoring.iam_role_arn != null ? 0 : 1
    ) : 0
  ) : 0

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
        Action = ["sts:AssumeRole"]
      }
    ]
  })

  description           = "Allow ${var.name} to upload data to Enhanced Monitoring"
  force_detach_policies = true
  name                  = "${var.name}-enhanced-monitoring"

  tags = merge(
    local.common_tags,
    var.additional_tags_all
  )
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count = var.monitoring_config != null ? (
    var.monitoring_config.enable_enhanced_monitoring != null ? (
      var.monitoring_config.enable_enhanced_monitoring.iam_role_arn != null ? 0 : 1
    ) : 0
  ) : 0

  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
