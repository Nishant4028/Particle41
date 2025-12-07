output "resource_group_name" { 
    value = azurerm_resource_group.rg.name
}

output "vnet_id" {
    value = module.network.vnet_id 
}

output "aks_name" {
    value = module.aks.aks_name
}

output "kube_config" {
    value = module.aks.kube_config
    sensitive = true
}

output "app_gatway_id" {
    value = module.appgw.appgw_id
}