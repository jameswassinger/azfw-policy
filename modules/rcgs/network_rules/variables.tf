variable "rule_collection_group_name" {
  description = "The rule collection groups to use for the firewall policy."
  type        = string
}

variable "rule_collection_names" {
  description = "The rule collections to use for the firewall policy."
  type        = list(string)
}

variable "firewall_policy_name" {
  description = "The name of the firewall policy."
  type        = string
}

variable "deployment_tier" {
  description = "The name of the deployment."
  type        = string
  validation {
    condition     = contains(["dev", "prd"], var.deployment_tier)
    error_message = "Valid values for deployment_tier are dev or prod."
  }
}

variable "existing_resource_group_name" {
  description = "The name of the existing resource group in which the firewall policy will be located."
  type        = string
}

variable "rcg_priority" {
  description = "The priority of the rule collection group."
  type        = number

}

variable "ip_group_ids" {
  type = map(string)
}