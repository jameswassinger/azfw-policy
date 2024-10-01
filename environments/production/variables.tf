variable "tenant_id" {
  description = "The Azure tenant ID"
  type        = string
}

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "tier" {
  description = "The tier of the service"
  type        = string
  validation {
    condition     = contains(["dev", "uat", "prd"], var.tier)
    error_message = "Tier must be either dev, uat, or prd"
  }
}


variable "existing_rg_name" {
  description = "The name of the existing resource group"
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace"
  type        = string

}

variable "fw_policy_name" {
  description = "The name of the firewall policy"
  type        = string
}

variable "fw_policy_sku" {
  description = "The SKU of the firewall policy"
  type        = string

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.fw_policy_sku)
    error_message = "SKU must be either Standard or Premium"
  }

}

variable "snat_private_ip_address" {
  description = "The private IP address to use for SNAT."
  type        = list(string)
}

variable "ip_groups" {
  description = "The IP groups to use for the firewall policy."
  type = list(object({
    name         = string
    ip_addresses = list(string)
  }))
}

variable "rule_collection_names" {
  description = "The rule collections to use for the firewall policy."
  type        = list(string)
}