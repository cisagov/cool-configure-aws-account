output "service_quotas" {
  description = "All requested service quotas."
  value       = aws_servicequotas_service_quota.all
}

output "sso_group_assignments" {
  description = "The permission set assignments of each SSO group in each AWS account."
  value       = aws_ssoadmin_account_assignment.group
}

output "sso_user_assignments" {
  description = "The permission set assignments of each SSO user in each AWS account."
  value       = aws_ssoadmin_account_assignment.user
}
