output "service_quotas" {
  value       = aws_servicequotas_service_quota.all
  description = "All requested service quotas."
}

output "sso_group_assignments" {
  value       = aws_ssoadmin_account_assignment.group
  description = "The permission set assignments of each SSO group in each AWS account."
}

output "sso_user_assignments" {
  value       = aws_ssoadmin_account_assignment.user
  description = "The permission set assignments of each SSO user in each AWS account."
}
