tier                         = "prd"
existing_rg_name             = "rg-firewallpolicies"
log_analytics_workspace_name = "law-firewallpolicies"
fw_policy_name               = "fw-policy"
fw_policy_sku                = "Basic"
snat_private_ip_address = [
  "164.119.0.0/16",
  "10.0.0.0/8",
  "172.16.0.0/12",
  "192.168.0.0/16",
  "100.64.0.0/10"
]
ip_groups = [
  {
    name = "ipg-vm-subnet"
    ip_addresses = [
      "10.0.2.0/23",
      "10.0.4.0/23",
      "10.0.6.0/23"
    ]
  },
  {
    name = "ipg-swa-subnet"
    ip_addresses = [
      "10.0.136.0/23",
      "10.0.138.0/23"
    ]
  }
]
rule_collection_names = [
  "AzureToOnprem",
  "OnpremToAzure",
  "AzureToAzure",
  "AzureToInternet",
  "Deny"
]
