# Fetch our SSO instance
data "aws_ssoadmin_instances" "current" {}

# Fetch all required permission sets
data "aws_ssoadmin_permission_set" "all" {
  for_each = local.all_permission_sets

  # The arns value is currently a set containing a single item
  instance_arn = tolist(data.aws_ssoadmin_instances.current.arns)[0]
  name         = each.value
}
