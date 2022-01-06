# Fetch our SSO instance
data "aws_ssoadmin_instances" "current" {}

# Fetch all required permission sets
data "aws_ssoadmin_permission_set" "all" {
  for_each = local.all_permission_sets

  instance_arn = tolist(data.aws_ssoadmin_instances.current.arns)[0]
  name         = each.value
}

# Fetch all required groups
data "aws_identitystore_group" "all" {
  for_each = local.all_groups

  identity_store_id = tolist(data.aws_ssoadmin_instances.current.identity_store_ids)[0]

  filter {
    attribute_path  = "DisplayName"
    attribute_value = each.value
  }
}

# Fetch all required users
data "aws_identitystore_user" "all" {
  for_each = local.all_usernames

  identity_store_id = tolist(data.aws_ssoadmin_instances.current.identity_store_ids)[0]

  filter {
    attribute_path  = "UserName"
    attribute_value = each.value
  }
}

# For each account (in local.accounts_to_configure) give each group (in
# var.groups_to_add_access_to) access to the specified permission sets
resource "aws_ssoadmin_account_assignment" "group" {
  for_each = {
    for i in local.groups_to_add_access_to : "${i.account_id}_${i.group}" => i
  }

  instance_arn       = data.aws_ssoadmin_permission_set.all[each.value.permission_set].instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.all[each.value.permission_set].arn
  principal_id       = data.aws_identitystore_group.all[each.value.group].group_id
  principal_type     = "GROUP"
  target_id          = each.value.account_id
  target_type        = "AWS_ACCOUNT"
}

# To remove permission sets from users that were not created by Terraform
# (such as those automatically created by AWS Control Tower), we must use
# Terraform's local-exec provisioner
resource "null_resource" "remove_user" {
  for_each = {
    for i in local.users_to_remove_access_from : "${i.account_id}_${i.user}" => i
  }

  provisioner "local-exec" {
    # This command asks AWS to delete the specified permission set from the
    # specified SSO user, then loops until the command completes.
    # NOTE: This command requires the "aws" and "jq" tools be installed on
    # your local system.  On macOS, these can be installed via:
    #   brew install awscli jq
    command = "REQUEST_ID=`aws --profile ${var.sso_admin_profile} --region ${var.aws_region} sso-admin delete-account-assignment --instance-arn ${data.aws_ssoadmin_permission_set.all[each.value.permission_set].instance_arn} --target-id ${each.value.account_id} --target-type AWS_ACCOUNT --permission-set-arn ${data.aws_ssoadmin_permission_set.all[each.value.permission_set].arn} --principal-type USER --principal-id ${data.aws_identitystore_user.all[each.value.user].user_id} | jq -r '.AccountAssignmentDeletionStatus.RequestId'` && echo RequestId=$REQUEST_ID && while [[ \"$STATUS\" != \"SUCCEEDED\" && \"$STATUS\" != \"FAILED\" ]]; do STATUS=`aws --profile ${var.sso_admin_profile} --region ${var.aws_region} sso-admin describe-account-assignment-deletion-status --instance-arn ${data.aws_ssoadmin_permission_set.all[each.value.permission_set].instance_arn} --account-assignment-deletion-request-id $REQUEST_ID | jq -r '.AccountAssignmentDeletionStatus.Status'`; echo Status=$STATUS; sleep 5; done && [ \"$STATUS\" = \"SUCCEEDED\" ]"
  }
}
