# ------------------------------------------------------------------------------
# Retrieve the effective Account ID, User ID, and ARN in which Terraform is
# authorized.  This is used to calculate the session names for assumed roles.
# ------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# Retrieve the information for all accouts in the organization.  This is used
# to lookup the Users account ID for use in the assume role policy.
# ------------------------------------------------------------------------------
data "aws_organizations_organization" "org" {
  provider = aws.organizationsreadonly
}

# ------------------------------------------------------------------------------
# Evaluate expressions for use throughout this configuration.
# ------------------------------------------------------------------------------
locals {
  # Extract the user name of the current caller for use
  # as assume role session names.
  caller_user_name = split("/", data.aws_caller_identity.current.arn)[1]

  # Determine which AWS accounts in the organization to configure, based on
  # the account_name_regex input variable.
  accounts_to_configure = toset([
    for account in data.aws_organizations_organization.org.non_master_accounts :
    account.id
    if length(regexall(var.account_name_regex, account.name)) > 0
  ])

  # Build the set of all group names in
  # var.groups_to_add_access_to and var.groups_to_remove_access_from
  all_groups = toset([for i in concat(var.groups_to_add_access_to, var.groups_to_remove_access_from) : i.group])

  # Build the set of all permission set names in the input variables
  all_permission_sets = toset(flatten([
    for i in concat(var.groups_to_add_access_to, var.groups_to_remove_access_from, var.users_to_add_access_to, var.users_to_remove_access_from) : i.permission_sets
  ]))

  # Build the set of all usernames in
  # var.users_to_add_access_to and var.users_to_remove_access_from
  all_usernames = toset([for i in concat(var.users_to_add_access_to, var.users_to_remove_access_from) : i.username])

  # Build a list of groups to add access to (for each account to configure)
  # that can be fed into a for_each loop
  groups_to_add_access_to = flatten([
    for account in local.accounts_to_configure : [
      for g in var.groups_to_add_access_to : [
        for ps in g.permission_sets : {
          account_id     = account
          group          = g.group
          permission_set = ps
        }
      ]
    ]
  ])

  # Build a list of groups to remove access from (for each account to
  # configure) that can be fed into a for_each loop
  groups_to_remove_access_from = flatten([
    for account in local.accounts_to_configure : [
      for g in var.groups_to_remove_access_from : [
        for ps in g.permission_sets : {
          account_id     = account
          group          = g.group
          permission_set = ps
        }
      ]
    ]
  ])

  # Build a list of users to add access to (for each account to configure)
  # that can be fed into a for_each loop
  users_to_add_access_to = flatten([
    for account in local.accounts_to_configure : [
      for u in var.users_to_add_access_to : [
        for ps in u.permission_sets : {
          account_id     = account
          user           = u.username
          permission_set = ps
        }
      ]
    ]
  ])

  # Build a list of users to remove access from (for each account to configure)
  # that can be fed into a for_each loop
  users_to_remove_access_from = flatten([
    for account in local.accounts_to_configure : [
      for u in var.users_to_remove_access_from : [
        for ps in u.permission_sets : {
          account_id     = account
          user           = u.username
          permission_set = ps
        }
      ]
    ]
  ])
}
