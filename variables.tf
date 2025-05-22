# ------------------------------------------------------------------------------
# REQUIRED PARAMETERS
#
# You must provide a value for each of these parameters.
# ------------------------------------------------------------------------------
variable "account_name_regex" {
  description = "The Terraform regular expression matching the name of the account(s) that you want to configure (e.g. \"^[[:alnum:]]-production$\").  See [https://www.terraform.io/language/functions/regex] for details on Terraform regular expression syntax."
  nullable    = false
  type        = string
}

variable "account_quota_profile" {
  description = "The name of the AWS profile (typically found in your .aws/credentials file) whose role has permissions to manage service quotas for the account to configure.  For an example, look at the AWS \"ServiceQuotasFullAccess\" policy: [https://docs.aws.amazon.com/servicequotas/latest/userguide/identity-access-management.html]."
  nullable    = false
  type        = string
}

variable "master_account_workspace" {
  description = "The name of the Terraform workspace where the master account remote state is stored (e.g. \"production\").  This corresponds to the name of the environment where the master account was provisioned."
  nullable    = false
  type        = string
}

variable "sso_admin_profile" {
  description = "The name of the AWS profile (typically found in your .aws/credentials file) to use for the default Terraform provider.  This profile's role must include permissions to administer Single Sign-On (SSO) resources.  For an example of a role like this, look at [https://github.com/cisagov/cool-accounts/pull/95]."
  nullable    = false
  type        = string
}

variable "terraform_state_bucket" {
  description = "The name of the S3 bucket where Terraform state is stored."
  nullable    = false
  type        = string
}

# ------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
#
# These parameters have reasonable defaults.
# ------------------------------------------------------------------------------

variable "aws_region" {
  default     = "us-east-1"
  description = "The AWS region to deploy into (e.g. us-east-1)."
  nullable    = false
  type        = string
}

variable "groups_to_add_access_to" {
  default     = []
  description = "A list of objects specifying Single Sign-On (SSO) groups to add permissions to.  Each object contains the SSO group name and the list of permission sets to add access to.  Example: [{ group = \"Admins\", permission_sets = [\"AWSAdministratorAccess\"] }]"
  nullable    = false
  type        = list(object({ group = string, permission_sets = list(string) }))
}

variable "groups_to_remove_access_from" {
  default     = []
  description = "A list of objects specifying Single Sign-On (SSO) groups to remove permissions from.  Each object contains the SSO group name and the list of permission sets to remove access from.  Example: [{ group = \"NonAdmins\", permission_sets = [\"AWSAdministratorAccess\"] }]"
  nullable    = false
  type        = list(object({ group = string, permission_sets = list(string) }))
}

variable "service_quotas" {
  default     = []
  description = "A list of objects specifying service quotas to request.  Each object contains a name, quota code, service code, and value for the quota.  Example: [{ name = \"Elastic IPs\", quota_code = \"L-0263D0A3\", service_code = \"ec2\", value = 10 }]"
  nullable    = false
  type        = list(object({ name = string, quota_code = string, service_code = string, value = number }))
}

variable "users_to_add_access_to" {
  default     = []
  description = "A list of objects specifying Single Sign-On (SSO) users to add permissions to.  Each object contains the SSO username and the list of permission sets to add access to.  Example: [{ username = \"john.doe@example.com\", permission_sets = [\"AWSAdministratorAccess\"] }]"
  nullable    = false
  type        = list(object({ username = string, permission_sets = list(string) }))
}

variable "users_to_remove_access_from" {
  default     = []
  description = "A list of objects specifying Single Sign-On (SSO) users to remove permissions from.  Each object contains the SSO username and the list of permission sets to remove access from.  Example: [{ username = \"john.doe@example.com\", permission_sets = [\"AWSAdministratorAccess\"] }]"
  nullable    = false
  type        = list(object({ username = string, permission_sets = list(string) }))
}

variable "tags" {
  default     = {}
  description = "Tags to apply to all AWS resources created."
  nullable    = false
  type        = map(string)
}
