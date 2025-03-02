module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
}

resource "azapi_resource_action" "resource_provider_registration" {
  for_each = local.resource_providers_to_register

  resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  type        = "Microsoft.Resources/subscriptions@2021-04-01"
  action      = "providers/${each.value.resource_provider}/register"
  method      = "POST"
}

#region Runners
module "github_runners" {
  source  = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
  version = "0.3.2"

  postfix                                      = "atn-runners"
  location                                     = local.selected_region
  version_control_system_organization          = var.github_organization_name
  version_control_system_personal_access_token = var.github_runners_personal_access_token
  version_control_system_type                  = "github"
  version_control_system_repository            = github_repository.bootstrap_runners.name
  compute_types                                = local.compute_types
  container_instance_container_cpu             = 2
  container_instance_container_cpu_limit       = 2
  container_instance_container_memory          = 4
  container_instance_container_memory_limit    = 4
  container_instance_container_name            = "${module.naming.container_app.name}-atn-runners"
  container_instance_count                     = 2
  use_private_networking                       = false
  tags                                         = local.tags
  #depends_on                                   = [github_repository_file.this]
}
#endregion Runners

resource "azurerm_federated_identity_credential" "github_runners" {
  name                = "atn-runners-fed-cred"
  resource_group_name = "rg-atn-runners"
  audience            = ["api://AzureADTokenExchange"]
  issuer              = "https://token.actions.githubusercontent.com"
  parent_id           = module.github_runners.user_assigned_managed_identity_id
  subject             = "repo:Azure-At-Night/bootstrap-runners:ref:refs/heads/main"
}
