resource "azurerm_public_ip" "pip" {
  name                = "pip-appgw"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_application_gateway" "agw" {
  name                = var.appgw_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name = var.sku_name   # e.g., "WAF_v2"
    tier = var.sku_name
  }

  autoscale_configuration {
    min_capacity = var.min_capacity
  }

  gateway_ip_configuration {
    name      = "appgw-ipcfg"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = "appgw-frontend"
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  backend_address_pool {
    name = "default-backend-pool"
  }

  backend_http_settings {
    name                  = "default-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "appgw-frontend"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                      = "default-rule"
    rule_type                 = "Basic"
    http_listener_name         = "http-listener"
    backend_http_settings_name = "default-http-settings"
    backend_address_pool_name =  "default-backend-pool"
    priority                  = 100
  }

  # WAF configuration (only once, directly under the resource)
  waf_configuration {
     enabled          = true
    firewall_mode    = "Prevention"  # or "Detection"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }

  tags = var.tags
}
