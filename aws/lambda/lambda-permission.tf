resource "aws_lambda_permission" "permissions" {
  for_each = var.lambda_permissions

  statement_id       = each.key
  event_source_token = each.value.event_source_token
  function_name      = aws_lambda_function.function.function_name
  principal_org_id   = each.value.policy_type != "aws_service" ? each.value.principal_organization_id : null
  source_account     = each.value.policy_type == "aws_service" ? each.value.source_account_id : null
  source_arn         = each.value.policy_type == "aws_service" ? each.value.source_arn : null

  action = each.value.action != null ? each.value.action : (
    each.value.policy_type == "function_url" ? "lambda:InvokeFunctionUrl" : "lambda:InvokeFunction"
  )

  function_url_auth_type = each.value.policy_type == "function_url" ? (
    each.value.function_url_auth_type != null ? each.value.function_url_auth_type : "AWS_IAM"
  ) : null

  # Check to see if an account ID is input, 12 digits number
  principal = length(regexall("\\d{12}", substr(each.value.principal, 0, 12))) > 0 ? (
    # Expand account ID to arn if so
    "arn:aws:iam::${each.value.principal}:root"
  ) : each.value.principal
}
