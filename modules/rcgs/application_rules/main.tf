locals {
  application_fw_rules = {

    /* 
      Available Properties:
      - name: The name of the rule.
      - description: The description of the rule.
      - protocols: The list of protocols that the rule applies to. Possible values are 'Http', 'Https', 'Mssql', 'Icmp', 'All'.
      - target_fqdns: The list of fully qualified domain names (FQDN) that the rule applies to.
      - source_addresses: The list of source IP addresses that the rule applies to.
      - source_ip_groups: The list of source IP groups that the rule applies to.
      - fqdn_tags: The list of FQDN tags that the rule applies to.
     */

    /* 
        Available Protocols:
        - Http
        - Https
        - Mssql
        - Icmp
        - All
     */

    /*
        source_ip_groups format:
        source_ip_groups = [var.ip_group_ids["<ip_group_name"]]
     */

    // Application Rules for Azure to Onprem
    "AppAzureToOnprem" = {
      rules = [
        {
          name        = "Test Azure to Onprem Rule"
          description = "Allow Azure to Onprem"
          protocols = [
            {
              type = "Https"
              port = 443
            }
          ]
          target_fqdns = [
            "onprem.jw2.com"
          ]
          source_addresses = ["10.112.3.0/32"]
        }

      ]
    },
    "AppOnpremToAzure" = {
      rules = [
        {
          name        = "Test Onprem to Azure Rule"
          description = "Allow Onprem to Azure"
          protocols = [
            {
              type = "Https"
              port = 443
            }
          ]
          target_fqdns = [
            "onprem.jw2.com"
          ]
          source_addresses = ["10.13.35.12"]
        }
      ]
    },

    // Application Rules for Azure to Azure
    "AppAzureToAzure" = {
      rules = [
        {

          name        = "Kubernetes Ubuntu MS Azure GitHub"
          description = "Kubernetes Ubuntu MS Azure GitHub"
          protocols = [
            {
              type = "Http"
              port = 80
            },
            {
              type = "Https"
              port = 443
            }
          ]
          target_fqdns = [
            "apt.kubernetes.io",
            "kubernetes.github.io",
            "azure.archive.ubuntu.com",
            "security.ubuntu.com",
            "entropy.ubuntu.com",
            "archive.ubuntu.com",
            "*.blob.storage.azure.net",
            "packages.microsoft.com",
            "management.azure.com",
            "github.com",
            "github-releases.githubusercontent.com"
          ]
          source_addresses = ["10.112.182.0/26"]
        }
      ]
    },

    // Application Rules for Azure to Internet
    "AppAzureToInternet" = {
      rules = [
        {
          name        = "Test Azure to Internet Rule"
          description = "Allow Azure to Internet"
          protocols = [
            {
              type = "Https"
              port = 443
            }
          ]
          target_fqdns = [
            "www.bing.com"
          ]
          source_addresses = ["10.32.5.1"]

        }
      ]
    },

    // Application Rules for Deny
    "AppDeny" = {
      rules = [{
        name        = "Test Deny Rule"
        description = "Deny Internet Access to a specific IP"
        protocols = [{
          type = "Https"
          port = 443
        }]
        fqdn_tags        = ["Internet"]
        source_addresses = ["246.199.111.81"] // Note: This is an invalid IP address only used for an example. Please replace it with a valid IP address.
      }]
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
  dynamic "application_rule_collection" {
    for_each = var.rule_collection_names
    content {
      name     = "App${application_rule_collection.value}"
      action   = strcontains(application_rule_collection.value, "Deny") ? "Deny" : "Allow"
      priority = (index(var.rule_collection_names, application_rule_collection.value) + 1) * 100
      dynamic "rule" {
        for_each = local.application_fw_rules["App${application_rule_collection.value}"].rules
        content {
          name        = rule.value.name
          description = lookup(rule.value, "descripton", null)
          dynamic "protocols" {
            for_each = lookup(rule.value, "protocols", null)
            content {
              type = protocols.value.type
              port = protocols.value.port
            }
          }
          destination_fqdns     = lookup(rule.value, "target_fqdns", null)
          destination_fqdn_tags = lookup(rule.value, "fqdn_tags", null)
          terminate_tls         = false
          source_addresses      = lookup(rule.value, "source_addresses", null)
          source_ip_groups      = lookup(rule.value, "source_ip_groups", null)
        }
      }
    }
  }
}