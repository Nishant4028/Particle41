output "appgw_id" {
  description = "ID - Application gateway"
  value = azurerm_application_gateway.agw.id
}

output "app_public_ip" {
   value = azurerm_public_ip.pip.ip_address 
}

output "appgw_frontend_config_name" {
  description = "Frontend configuration name"
  value = azurerm_application_gateway.agw.frontend_ip_configuration[0].name
}