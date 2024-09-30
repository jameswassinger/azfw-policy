locals {
  network_fw_rules = {

    /*
      Available properties: 
      - name
      - description
      - protocols
      - source_ip_groups
      - source_addresses
      - destination_ip_groups
      - destination_addresses
      - destination_fqdns
      - destination_ports
    */

    /*
      Available protocols: 
      - TCP
      - UDP
      - ICMP
      - Any
    */

    /*
      Using source_ip_groups and destination_ip_groups is recommended for better performance: 
      - source_ip_groups: List of IP Group IDs that define the source IP addresses for the rule.
      - destination_ip_groups: List of IP Group IDs that define the destination IP addresses for the rule.
      format: var.ip_group_ids["<ip_group_name>"]
    */

    // Network rules for Azure to Onprem
    "NetAzureToOnprem" = {
      rules = [
        {
          name                  = "TestAllowAzureToOnprem"
          description           = "Allow Azure to Onprem"
          protocols             = ["TCP"]
          source_addresses      = ["10.2.0.35"]
          destination_ports     = ["443"]
          destination_addresses = ["10.5.1.25"]
        }
      ]
    },

    // Network rules for Onprem to Azure
    "NetOnpremToAzure" = {
      rules = [
        {
          name                  = "TestAllowOnpremToAzure"
          description           = "Allow Onprem to Azure"
          protocols             = ["TCP"]
          source_addresses      = ["10.5.1.25"]
          destination_ports     = ["443"]
          destination_addresses = ["10.2.0.35"]
        }
      ]
    },

    // Network rules for Azure to Azure
    "NetAzureToAzure" = {
      rules = [
        {
          name                  = "TestAllowAzureToAzure"
          description           = "Allow Azure to Azure"
          protocols             = ["TCP"]
          source_addresses      = ["10.2.0.35"]
          destination_ports     = ["443"]
          destination_addresses = ["10.2.0.45"]
        }
      ]
    },

    // Network rules for Azure to Internet
    "NetAzureToInternet" = {
      rules = [
        {
          name              = "TestAllowAzureToInternet"
          description       = "Deny Azure to Onprem"
          protocols         = ["TCP"]
          source_addresses  = ["10.2.0.45"]
          destination_ports = ["443"]
          destination_addresses = ["8.8.8.8"]
        }
      ]
    },

    // Network Deny rules
    "NetDeny" = {
      rules = [
        {
          name              = "TestDenyAzureToOnprem"
          description       = "Deny Azure to Onprem"
          protocols         = ["TCP"]
          source_addresses  = ["10.2.0.45"]
          destination_ports = ["443"]
          destination_fqdns = ["10.1.2.104"]
        }
      ]
    }
  }
}

data "azurerm_resource_group" "rg_fwpolicy" {
  name = var.existing_resource_group_name
}

data "azurerm_firewall_policy" "fwpolicy" {
  name                = var.firewall_policy_name
  resource_group_name = data.azurerm_resource_group.rg_fwpolicy.name
}

resource "azurerm_firewall_policy_rule_collection_group" "rule_collection_group" {
  name               = var.rule_collection_group_name
  firewall_policy_id = data.azurerm_firewall_policy.fwpolicy.id
  priority           = var.rcg_priority
  dynamic "network_rule_collection" {
    for_each = var.rule_collection_names
    content {
      name     = "Net${network_rule_collection.value}"
      action   = strcontains(network_rule_collection.value, "Deny") ? "Deny" : "Allow"
      priority = (index(var.rule_collection_names, network_rule_collection.value) + 1) * 100
      dynamic "rule" {
        for_each = local.network_fw_rules["Net${network_rule_collection.value}"].rules
        content {
          name                  = rule.value.name
          description           = lookup(rule.value, "descripton", null)
          protocols             = lookup(rule.value, "protocols", null)
          destination_ports     = lookup(rule.value, "destination_ports", null)
          source_addresses      = lookup(rule.value, "source_addresses", null)
          source_ip_groups      = lookup(rule.value, "source_ip_groups", null)
          destination_addresses = lookup(rule.value, "destination_addresses", null)
          destination_ip_groups = lookup(rule.value, "destination_ip_groups", null)
          destination_fqdns     = lookup(rule.value, "destination_fqdns", null)
        }
      }
    }
  }
}