resource "aws_scheduler_schedule_group" "schedule_group" {
  name = var.name

  tags = merge(
    local.common_tags,
    var.additional_tags,
    var.additional_tags_all
  )
}
