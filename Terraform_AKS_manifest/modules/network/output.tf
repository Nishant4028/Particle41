output "vnet_id" {
  value = azurerm_virtual_network.Vnet.id  
}

output "subnet_public_agw_id" {
  value =   azurerm_subnet.public_agw.id
}

output "subnet_public_dmz_id" {
  value = azurerm_subnet.public_dmz.id
}

output "subnet_private_sys_id" {
    value = azurerm_subnet.private_sys.id
}

output "subnet_private_user_id" {
    value = azurerm_subnet.private_user.id
}
