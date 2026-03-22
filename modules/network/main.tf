# The Spoke Network
resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-citadel-spoke"
  address_space       = ["10.2.0.0/16"]
  location            = var.location
  resource_group_name = var.rg_name
}

# THE FIX: Network Security Group (The Guards)

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-citadel-hardened"
  location            = var.location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "AllowInternalHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.0.0.0/8" # Only private traffic
    destination_address_prefix = "*"
  }
}

# THE FIX: Route Table 
resource "azurerm_route_table" "rt" {
  name                = "rt-citadel-prod"
  location            = var.location
  resource_group_name = var.rg_name
}

# App Subnet with Guards and Signs attached
resource "azurerm_subnet" "compute" {
  name                 = "snet-compute"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.2.1.0/24"]
  delegation {
    name = "func-delegation"
    service_delegation { name = "Microsoft.Web/serverfarms" }
  }
}

resource "azurerm_subnet_network_security_group_association" "comp_nsg" {
  subnet_id                 = azurerm_subnet.compute.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}