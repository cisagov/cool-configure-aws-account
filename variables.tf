# ------------------------------------------------------------------------------
# REQUIRED PARAMETERS
#
# You must provide a value for each of these parameters.
# ------------------------------------------------------------------------------
variable "account_name_regex" {
  type        = string
  description = "The Terraform regular expression matching the name of the account(s) that you want to configure (e.g. \"^[[:alnum:]]-production$\").  See [https://www.terraform.io/language/functions/regex] for details on Terraform regular expression syntax."
}

variable "sso_admin_profile" {
  type        = string
  description = "The name of the AWS profile (typically found in your .aws/credentials file) to use for the default Terraform provider.  This profile's role must include permissions to administer Single Sign-On (SSO) resources.  For an example of a role like this, look at [https://github.com/cisagov/cool-accounts/pull/95]."
}

# ------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
#
# These parameters have reasonable defaults.
# ------------------------------------------------------------------------------

variable "aws_region" {
  type        = string
  description = "The AWS region to deploy into (e.g. us-east-1)."
  default     = "us-east-1"
}

variable "groups_to_add_access_to" {
  type        = list(object({ group = string, permission_sets = list(string) }))
  description = "A list of objects specifying Single Sign-On (SSO) groups to add permissions to.  Each object contains the SSO group name and the list of permission sets to add access to.  Example: [{ group = \"Admins\", permission_sets = [\"AWSAdministratorAccess\"] }]"
  default     = []
}

variable "groups_to_remove_access_from" {
  type        = list(object({ group = string, permission_sets = list(string) }))
  description = "A list of objects specifying Single Sign-On (SSO) groups to remove permissions from.  Each object contains the SSO group name and the list of permission sets to remove access from.  Example: [{ group = \"NonAdmins\", permission_sets = [\"AWSAdministratorAccess\"] }]"
  default     = []
}

variable "users_to_add_access_to" {
  type        = list(object({ username = string, permission_sets = list(string) }))
  description = "A list of objects specifying Single Sign-On (SSO) users to add permissions to.  Each object contains the SSO username and the list of permission sets to add access to.  Example: [{ username = \"john.doe@example.com\", permission_sets = [\"AWSAdministratorAccess\"] }]"
  default     = []
}

variable "users_to_remove_access_from" {
  type        = list(object({ username = string, permission_sets = list(string) }))
  description = "A list of objects specifying Single Sign-On (SSO) users to remove permissions from.  Each object contains the SSO username and the list of permission sets to remove access from.  Example: [{ username = \"john.doe@example.com\", permission_sets = [\"AWSAdministratorAccess\"] }]"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all AWS resources created."
  default     = {}
}
