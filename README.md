# cool-configure-aws-account #

[![GitHub Build Status](https://github.com/cisagov/cool-configure-aws-account/workflows/build/badge.svg)](https://github.com/cisagov/cool-configure-aws-account/actions)

This repository contains Terraform code for configuring AWS accounts
for use in the COOL.

## Pre-requisites ##

- A valid AWS profile that has permissions to administer Single Sign-On (SSO)
  resources, similar to
  [this policy](https://github.com/cisagov/cool-accounts/blob/develop/master/administersso_policy.tf).
- A valid AWS profile that has permissions to manage service quotas, similar
  to the AWS `ServiceQuotasFullAccess` policy (see
  [here](https://docs.aws.amazon.com/servicequotas/latest/userguide/identity-access-management.html)
  for more information).  If you used
  [`cisagov/provisionaccount-role-tf-module`](https://github.com/cisagov/provisionaccount-role-tf-module)
  to create your account-provisioning role, then
  [that policy is
  already attached](https://github.com/cisagov/provisionaccount-role-tf-module/blob/847a0b9c581d5b18ce8574fb4579765a15151462/provision_role.tf#L17-L21)
  to your account-provisioning role.
- [Terraform](https://www.terraform.io/) installed on your system.
- The [AWS CLI](https://aws.amazon.com/cli/) installed on your system.
- [jq](https://stedolan.github.io/jq/) installed on your system.
- An accessible AWS S3 bucket to store Terraform state
  (specified in [`backend.tf`](backend.tf)).
- An accessible AWS DynamoDB database to store the Terraform state lock
  (specified in [`backend.tf`](backend.tf)).
- A Terraform [variables](variables.tf) file customized for the AWS account(s)
  that you want to configure, for example:

  ```hcl
  account_name_regex = "^[[:alnum:]]-production$"
  groups_to_add_access_to = [
    {
      group           = "Admins",
      permission_sets = ["AWSAdministratorAccess"]
    }
  ]
  sso_admin_profile = "AdministerSSO"
  users_to_remove_access_from = [
    {
      username        = "john.doe@example.com",
      permission_sets = ["AWSAdministratorAccess"]
    }
  ]
  ```

## Usage ##

1. Create a Terraform workspace (if you haven't already done so) by running
   `terraform workspace new <workspace_name>`.
1. Create a `<workspace_name>.tfvars` file with all of the required
   variables (see [Inputs](#Inputs) below for details).
1. Run the command `terraform init`.
1. Provision the new AWS account(s) by running the command:

   ```console
   terraform apply -var-file=<workspace_name>.tfvars
   ```

## Requirements ##

| Name | Version |
|------|---------|
| terraform | ~> 1.0 |
| aws | ~> 3.38 |

## Providers ##

| Name | Version |
|------|---------|
| aws | ~> 3.38 |
| aws.organizationsreadonly | ~> 3.38 |
| aws.quotas | ~> 3.38 |
| null | n/a |
| terraform | n/a |

## Modules ##

No modules.

## Resources ##

| Name | Type |
|------|------|
| [aws_servicequotas_service_quota.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/servicequotas_service_quota) | resource |
| [aws_ssoadmin_account_assignment.group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_ssoadmin_account_assignment.user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [null_resource.remove_group](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.remove_user](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_identitystore_group.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_group) | data source |
| [aws_identitystore_user.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_user) | data source |
| [aws_organizations_organization.org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_ssoadmin_instances.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |
| [aws_ssoadmin_permission_set.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_permission_set) | data source |
| [terraform_remote_state.master](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs ##

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account\_name\_regex | The Terraform regular expression matching the name of the account(s) that you want to configure (e.g. "^[[:alnum:]]-production$").  See [https://www.terraform.io/language/functions/regex] for details on Terraform regular expression syntax. | `string` | n/a | yes |
| account\_quota\_profile | The name of the AWS profile (typically found in your .aws/credentials file) whose role has permissions to manage service quotas for the account to configure.  For an example, look at the AWS "ServiceQuotasFullAccess" policy: [https://docs.aws.amazon.com/servicequotas/latest/userguide/identity-access-management.html]. | `string` | n/a | yes |
| aws\_region | The AWS region to deploy into (e.g. us-east-1). | `string` | `"us-east-1"` | no |
| groups\_to\_add\_access\_to | A list of objects specifying Single Sign-On (SSO) groups to add permissions to.  Each object contains the SSO group name and the list of permission sets to add access to.  Example: [{ group = "Admins", permission\_sets = ["AWSAdministratorAccess"] }] | `list(object({ group = string, permission_sets = list(string) }))` | `[]` | no |
| groups\_to\_remove\_access\_from | A list of objects specifying Single Sign-On (SSO) groups to remove permissions from.  Each object contains the SSO group name and the list of permission sets to remove access from.  Example: [{ group = "NonAdmins", permission\_sets = ["AWSAdministratorAccess"] }] | `list(object({ group = string, permission_sets = list(string) }))` | `[]` | no |
| service\_quotas | A list of objects specifying service quotas to request.  Each object contains a name, quota code, service code, and value for the quota.  Example: [{ name = "Elastic IPs", quota\_code = "L-0263D0A3", service\_code = "ec2", value = 10 }] | `list(object({ name = string, quota_code = string, service_code = string, value = number }))` | `[]` | no |
| sso\_admin\_profile | The name of the AWS profile (typically found in your .aws/credentials file) to use for the default Terraform provider.  This profile's role must include permissions to administer Single Sign-On (SSO) resources.  For an example of a role like this, look at [https://github.com/cisagov/cool-accounts/pull/95]. | `string` | n/a | yes |
| tags | Tags to apply to all AWS resources created. | `map(string)` | `{}` | no |
| users\_to\_add\_access\_to | A list of objects specifying Single Sign-On (SSO) users to add permissions to.  Each object contains the SSO username and the list of permission sets to add access to.  Example: [{ username = "john.doe@example.com", permission\_sets = ["AWSAdministratorAccess"] }] | `list(object({ username = string, permission_sets = list(string) }))` | `[]` | no |
| users\_to\_remove\_access\_from | A list of objects specifying Single Sign-On (SSO) users to remove permissions from.  Each object contains the SSO username and the list of permission sets to remove access from.  Example: [{ username = "john.doe@example.com", permission\_sets = ["AWSAdministratorAccess"] }] | `list(object({ username = string, permission_sets = list(string) }))` | `[]` | no |

## Outputs ##

| Name | Description |
|------|-------------|
| service\_quotas | All requested service quotas. |
| sso\_group\_assignments | The permission set assignments of each SSO group in each AWS account. |
| sso\_user\_assignments | The permission set assignments of each SSO user in each AWS account. |

## Notes ##

Running `pre-commit` requires running `terraform init` in every directory that
contains Terraform code. In this repository, this is only the main directory.

## Contributing ##

We welcome contributions!  Please see [`CONTRIBUTING.md`](CONTRIBUTING.md) for
details.

## License ##

This project is in the worldwide [public domain](LICENSE).

This project is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain
dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0
dedication. By submitting a pull request, you are agreeing to comply
with this waiver of copyright interest.
