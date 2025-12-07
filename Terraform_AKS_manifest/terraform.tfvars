resource_group_name = "rg-aks-appgw3"
location = "Eastus2"
aks_name = "aks-private-cluster"
dns_prefix = "aksdev"

vnet_address_space = "10.10.0.0/16"

subnets = {
  public_agw = "10.10.0.0/24"
  public_dmz = "10.10.1.0/24"
  private_sys = "10.10.2.0/24"
  private_user = "10.10.3.0/24" 
}

system_vm_size = "Standard_D2s_v3"
user_vm_size = "Standard_D2s_v3"
system_node_count = 2
user_node_count = 3

service_cidr = "10.240.0.0/16"
dns_service_ip = "10.240.0.10"
network_plugin_mode ="overlay"

appgw_name = "appgw-aks"
appgw_sku = "WAF_v2"
