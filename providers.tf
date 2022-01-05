# This is the "default" provider that is used to manage resources
# inside the AWS account used for Single Sign On (SSO).
provider "aws" {
  default_tags {
    tags = var.tags
  }

  profile = "cool-master-administersso"
  region  = var.aws_region
}

# The provider used to lookup account IDs.  See locals.
provider "aws" {
  alias = "organizationsreadonly"
  assume_role {
    role_arn     = data.terraform_remote_state.master.outputs.organizationsreadonly_role.arn
    session_name = local.caller_user_name
  }
  default_tags {
    tags = var.tags
  }
  region = var.aws_region
}
