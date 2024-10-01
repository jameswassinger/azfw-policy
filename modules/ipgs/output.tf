output "ipg_ids" {
  value       = { for ipg in var.ip_groups : ipg.name => azurerm_ip_group.ipg[ipg.name].id }
  description = "value of azurerm_ip_group"
}