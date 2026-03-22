# 1. The Warehouse (The Storage Account)
resource "azurerm_storage_account" "st" {
  name                     = "stcitadelprodcan01"
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "ZRS" # 3-building redundancy
  
  # THE FIX: Shut the front door to the public internet
  public_network_access_enabled = false 
}

# 2. The Secret Tunnel (Private Endpoint)
resource "azurerm_private_endpoint" "st_pe" {
  # We use for_each to create one tunnel for 'blob' and one for 'queue'
  for_each            = toset(["blob", "queue"])
  
  name                = "pe-citadel-${each.key}"
  location            = var.location   
  resource_group_name = var.rg_name  
  subnet_id           = var.pe_subnet_id


  private_service_connection {
    name                           = "psc-citadel-${each.key}"
    private_connection_resource_id = azurerm_storage_account.st.id 
    is_manual_connection           = false     
    subresource_names              = [each.key]      
  }

  
  private_dns_zone_group {
    name                 = "citadel-dns-group"
    private_dns_zone_ids = [var.dns_ids[each.key]]
  }
}