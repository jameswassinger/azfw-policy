terraform {
  # Update this block with the location of your terraform state file
  backend "azurerm" {
    resource_group_name  = "rg-firewallpolicies"
    storage_account_name = "saghactionsfwpolicydev"
    container_name       = "tfstate"
    key                  = "development/terraform.tfstate"
    use_oidc             = true
  }
}