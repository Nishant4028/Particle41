resource "azurerm_virtual_network" "Vnet" {
    name = "vnet-aks"
    location            = var.location
    resource_group_name = var.resource_group_name
    address_space       = [var.vnet_address_space]
    tags                = var.tags
}

resource "azurerm_subnet" "public_agw" {
    name = "public-applicationgateway-subnet"
    resource_group_name = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.Vnet.name
    address_prefixes = [var.subnets.public_agw]
}

resource "azurerm_subnet" "public_dmz" {
    name                 = "public_dmz_subnet"
    resource_group_name  = var.resource_group_name
    virtual_network_name = azurerm_virtual_network.Vnet.name
    address_prefixes     = [var.subnets.public_dmz] 
}

resource "azurerm_subnet" "private_sys" {
    name = "aks_system_subnet" 
    resource_group_name = var.resource_group_name
    address_prefixes = [var.subnets.private_sys]
    virtual_network_name = azurerm_virtual_network.Vnet.name

    
  
}

resource "azurerm_subnet" "private_user" {
    name                 = "aks-user-subnet" 
    resource_group_name  = var.resource_group_name
    address_prefixes     = [var.subnets.private_user]
    virtual_network_name = azurerm_virtual_network.Vnet.name

    
}


# Optional route table (placeholder for future routes if needed)

resource "azurerm_route_table" "rt_private" {
    name = "rt-aks-private"
    location = var.location
    resource_group_name = var.resource_group_name
    tags =  var.tags
}

resource "azurerm_subnet_route_table_association" "rt_assoc_sys" {
    subnet_id       = azurerm_subnet.private_sys.id
    route_table_id  = azurerm_route_table.rt_private.id 
}

resource "azurerm_subnet_route_table_association" "rt_assoc_user" {
    subnet_id = azurerm_subnet.private_user.id
    route_table_id = azurerm_route_table.rt_private.id 
}