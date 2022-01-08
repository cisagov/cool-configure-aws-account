output "sso_group_assignments" {
  value       = aws_ssoadmin_account_assignment.group
  description = "The permission set assignments of each SSO group in each AWS account."
}
