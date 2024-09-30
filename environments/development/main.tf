data "azurerm_resource_group" "rg_fwpolicy" {
  name = var.existing_rg_name
}

resource "azurerm_log_analytics_workspace" "law_fwpolicy" {
  name                = var.log_analytics_workspace_name
  location            = data.azurerm_resource_group.rg_fwpolicy.location
  resource_group_name = data.azurerm_resource_group.rg_fwpolicy.name
  sku                 = "PerGB2018"
}




module "ip_groups" {
  source                       = "../../modules/ipgs"
  ip_groups                    = var.ip_groups
  existing_resource_group_name = data.azurerm_resource_group.rg_fwpolicy.name
  deployment_name              = var.tier
}


resource "azurerm_firewall_policy" "fwpolicy" {
  name                = "${var.fw_policy_name}-${var.tier}"
  resource_group_name = data.azurerm_resource_group.rg_fwpolicy.name
  location            = data.azurerm_resource_group.rg_fwpolicy.location
  sku                 = var.fw_policy_sku
  private_ip_ranges   = var.snat_private_ip_address
  insights {
    enabled                            = true
    default_log_analytics_workspace_id = azurerm_log_analytics_workspace.law_fwpolicy.id
    retention_in_days                  = 90
  }
}

module "network_collection_group" {
  source                       = "../../modules/rcgs/network_rules"
  rule_collection_group_name   = "DefaultNetworkRuleCollectionGroup"
  rule_collection_names        = var.rule_collection_names
  firewall_policy_name         = "${var.fw_policy_name}-${var.tier}"
  deployment_tier              = var.tier
  existing_resource_group_name = data.azurerm_resource_group.rg_fwpolicy.name
  rcg_priority                 = 100
  ip_group_ids                 = module.ip_groups.ipg_ids
  depends_on                   = [azurerm_firewall_policy.fwpolicy]
}

/*
module "application_collection_group" {
  source                       = "../../modules/rcgs/application_rules"
  rule_collection_group_name   = "DefaultApplicationRuleCollectionGroup"
  rule_collection_names        = var.rule_collection_names
  firewall_policy_name         = "${var.firewall_policy_name}-${var.deployment_name}"
  deployment_name              = var.deployment_name
  existing_resource_group_name = data.azurerm_resource_group.rg_fwpolicy.name
  rcg_priority                 = 200
  ip_group_ids                 = module.ip_groups.ipg_ids
  depends_on                   = [azurerm_firewall_policy.fwpolicy]
}
*/