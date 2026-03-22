resource "azurerm_linux_function_app" "func" {
  name                = "func-citadel-processor"
  location            = var.location
  resource_group_name = var.rg_name
  service_plan_id     = var.plan_id
  
  storage_account_name       = var.st_name
  storage_uses_managed_identity = true

 
  site_config {
    # This tells Azure: "Use the private tunnels we built for everything"
    vnet_route_all_enabled = true
    
    application_stack {
      python_version = "3.9"
    }
  }

  
  # This creates the fingerprint the app uses to talk to Storage
  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    # THE FIX: True Identity-Based Connection
    "AzureWebJobsStorage__accountName" = var.st_name
    "WEBSITE_RUN_FROM_PACKAGE"        = "1"
    "WEBSITE_VNET_ROUTE_ALL"          = "1"
    "WEBSITE_CONTENTOVERVNET"         = "1" # Force content over the tunnel
  }
}

# THE FIX: The "VNet Integration" (The Tunnel Entrance)
# This plugs the App into the subnet we delegated 
resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  app_service_id = azurerm_linux_function_app.func.id
  subnet_id      = var.compute_subnet_id
}