resource "aws_ecr_lifecycle_policy" "private_repository_lifecycle_policies" {
  for_each = var.private_registry != null ? { for k, v in var.private_registry.repositories : k => v if length(v.lifecycle_policy_rules) > 0 } : {}

  repository = aws_ecr_repository.private_repositories[each.key].name

  policy = jsonencode({
    rules = [
      for rule in each.value.lifecycle_policy_rules : merge(
        {
          rulePriority = rule.priority

          action = {
            type = "expire"
          }

          selection = merge(
            {
              tagStatus = rule.tag_filters != null ? (
                # use "any" if tag_filters = ["*"]
                contains(rule.tag_filters, "*") ? "any" : "tagged"
              ) : "untagged"

              countType = rule.match_criteria.days_since_image_pushed != null ? "sinceImagePushed" : (
                rule.match_criteria.image_count_more_than != null ? "imageCountMoreThan" : null
              )

              countNumber = rule.match_criteria.days_since_image_pushed != null ? rule.match_criteria.days_since_image_pushed : (
                rule.match_criteria.image_count_more_than != null ? rule.match_criteria.image_count_more_than : null
              )
            },
            rule.tag_filters != null ? (
              # filter is not needed if tagStatus = "any"
              contains(rule.tag_filters, "*") ? {} : (
                # use tagPatternList if any tag_filters has a "*", for example: tag_filters = ["prod*", "dev*"]
                # otherwise use tagPrefixList
                length([for filter in rule.tag_filters : filter if strcontains(filter, "*")]) > 0 ? { tagPatternList = rule.tag_filters } : { tagPrefixList = rule.tag_filters }
              )
            ) : {},
            rule.match_criteria.days_since_image_pushed != null ? { countUnit = "days" } : {}
          )
        },
        rule.description != null ? { description = rule.description } : {}
      )
    ]
  })
}
