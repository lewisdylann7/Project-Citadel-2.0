terraform {
  backend "azurerm" {
    resource_group_name  = "rg-citadel-mgmt-can"
    storage_account_name = "stcitadelstatedev01" 
    container_name       = "tfstate"
    key                  = "citadel.prod.tfstate"
    use_azuread_auth     = true
  }
}

# 2. (Provider)
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

# 3.(Resource Group)
resource "azurerm_resource_group" "rg" {
  name     = "rg-citadel-prod-can"
  location = var.location
}

# 4. (Network Module)
module "network" {
  source   = "../../modules/network"
  rg_name  = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
}

# 5.(Storage Module)
module "storage" {
  source        = "../../modules/storage"
  rg_name       = azurerm_resource_group.rg.name
  location      = azurerm_resource_group.rg.location
  pe_subnet_id  = module.network.compute_subnet_id 
}

# 6.(App Service Plan)
resource "azurerm_service_plan" "plan" {
  name                = "asp-citadel-prod"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "P1v2" 
}

# 7.(Compute Module)
module "compute" {
  source            = "../../modules/compute"
  rg_name           = azurerm_resource_group.rg.name
  location          = azurerm_resource_group.rg.location
  plan_id           = azurerm_service_plan.plan.id
  st_name           = module.storage.storage_name
  compute_subnet_id = module.network.compute_subnet_id
}

# 8. (Monitoring Module)
# We combine EVERYTHING into one 'locals' map here.
locals {
  citadel_telemetry_map = {
    vnet    = module.network.vnet_id
    storage = module.storage.storage_id
    compute = module.compute.function_id
  }
}

module "monitoring" {
  source       = "../../modules/monitoring"
  rg_name      = azurerm_resource_group.rg.name
  location     = azurerm_resource_group.rg.location
  resource_ids = local.citadel_telemetry_map
}