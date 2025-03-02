provider "azurerm" {
  subscription_id = var.management_subscription_id
  features {
  }
}

provider "github" {
  token = var.github_personal_access_token
  owner = var.github_organization_name
}
