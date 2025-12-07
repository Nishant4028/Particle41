resource "azurerm_resource_group" "rg" {
    name      = var.resource_group_name
    location  = var.location
    tags = var.tags
}

module "network" {
    source                 = "./modules/network"
    location               = var.location
    resource_group_name    = azurerm_resource_group.rg.name
    vnet_address_space     = var.vnet_address_space
    subnets                =  var.subnets
    tags                   = var.tags
}


module "appgw" {
    source         = "./modules/appgw"
    resource_group_name = azurerm_resource_group.rg.name
    location       = var.location   
    appgw_name     =  var.appgw_name
    sku_name       =  var.appgw_sku
    min_capacity   = var.appgw_min_capacity
    subnet_id      = module.network.subnet_public_agw_id
    tags           = var.tags
}

module "aks" {
    source = "./modules/aks"
    location             = var.location
    resource_group_name  = azurerm_resource_group.rg.name
    aks_name             = var.aks_name
    dns_prefix           = var.dns_prefix
    service_cidr         = var.service_cidr
    dns_service_ip       = var.dns_service_ip
    network_plugin_mode  = var.network_plugin_mode
    enable_private_cluster = var.enable_private_cluster
    system_subnet_id     = module.network.subnet_private_sys_id
    user_subnet_id       = module.network.subnet_private_user_id
    appgw_id             = module.appgw.appgw_id
    tags                 = var.tags 
    user_node_count      = var.user_node_count
    user_vm_size         = var.user_vm_size
    system_node_count    = var.system_node_count
    system_vm_size       = var.system_vm_size 
}
