resource "aws_guardduty_filter" "suppression_rules" {
  for_each = var.suppression_rules

  detector_id = aws_guardduty_detector.guardduty_detector.id
  name        = each.key
  description = each.value.description
  action      = "ARCHIVE"
  rank        = each.value.rank

  finding_criteria {
    dynamic "criterion" {
      for_each = each.value.criteria

      content {
        field                 = split(" ", replace(replace(criterion.value, "\"", ""), "'", ""))[0]
        equals                = split(" ", replace(replace(criterion.value, "\"", ""), "'", ""))[1] == "=" ? split(" ", replace(replace(criterion.value, "\"", ""), "'", ""))[2] : null
        not_equals            = split(" ", replace(replace(criterion.value, "\"", ""), "'", ""))[1] == "!=" ? split(" ", replace(replace(criterion.value, "\"", ""), "'", ""))[2] : null
        greater_than          = split(" ", replace(replace(criterion.value, "\"", ""), "'", ""))[1] == ">" ? split(" ", replace(replace(criterion.value, "\"", ""), "'", ""))[2] : null
        less_than             = split(" ", replace(replace(criterion.value, "\"", ""), "'", ""))[1] == "<" ? split(" ", replace(replace(criterion.value, "\"", ""), "'", ""))[2] : null
        greater_than_or_equal = split(" ", replace(replace(criterion.value, "\"", ""), "'", ""))[1] == ">=" ? split(" ", replace(replace(criterion.value, "\"", ""), "'", ""))[2] : null
        less_than_or_equal    = split(" ", replace(replace(criterion.value, "\"", ""), "'", ""))[1] == "<=" ? split(" ", replace(replace(criterion.value, "\"", ""), "'", ""))[2] : null
        matches               = split(" ", replace(replace(criterion.value, "\"", ""), "'", ""))[1] == "matches" ? [split(" ", replace(replace(criterion.value, "\"", ""), "'", ""))[2]] : null
        not_matches           = split(" ", replace(replace(criterion.value, "\"", ""), "'", ""))[1] == "not_matches" ? [split(" ", replace(replace(criterion.value, "\"", ""), "'", ""))[2]] : null
      }
    }
  }
}