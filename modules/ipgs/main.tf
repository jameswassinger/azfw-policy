data "azurerm_resource_group" "rg_fwpolicy" {
  name = var.existing_resource_group_name
}
resource "azurerm_ip_group" "ipg" {
  for_each            = { for ip_group in var.ip_groups : ip_group.name => ip_group }
  name                = "${each.value.name}-tf-${var.deployment_name}"
  location            = data.azurerm_resource_group.rg_fwpolicy.location
  resource_group_name = data.azurerm_resource_group.rg_fwpolicy.name
  cidrs               = each.value.ip_addresses

}