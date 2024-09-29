variable "ip_groups" {
  description = "The IP groups to use for the firewall policy."
  type = list(object({
    name         = string
    ip_addresses = list(string)
  }))
}

variable "existing_resource_group_name" {
  description = "The name of the existing resource group."
  type        = string
}

variable "deployment_name" {
  description = "The name of the deployment."
  type        = string
}