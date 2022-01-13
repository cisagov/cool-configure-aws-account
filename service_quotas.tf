# Apply service quotas
resource "aws_servicequotas_service_quota" "all" {
  for_each = {
    for q in var.service_quotas : "${q.service_code}_${q.name}" => q
  }
  provider = aws.quotas

  quota_code   = each.value.quota_code
  service_code = each.value.service_code
  value        = each.value.value
}
