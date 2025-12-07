resource "azurerm_kubernetes_cluster" "aks" {
    name                 = var.aks_name
    location             = var.location
    resource_group_name  = var.resource_group_name
    dns_prefix           = var.dns_prefix
    
    private_cluster_enabled = var.enable_private_cluster

    identity {
    type = "SystemAssigned"
    }

    network_profile {
      network_plugin = "azure"
      network_plugin_mode = var.network_plugin_mode
      service_cidr = var.service_cidr
      dns_service_ip = var.dns_service_ip
      outbound_type = "loadBalancer"
    }

    default_node_pool {
      name                   = "systemnp"
      vm_size                = var.system_vm_size
      node_count             = var.system_node_count
      vnet_subnet_id         = var.system_subnet_id

      only_critical_addons_enabled = true
      #node_taints            = ["CriticalAddonsOnly=true:NoSchedule"]
      tags                   = var.tags

    }


    role_based_access_control_enabled = true

   # addon_profile {
    #     ingress_application_gateway {
    #        enabled = true
    #        gateway_id = var.appgw.id
    #     }
    #}

    ingress_application_gateway {
      gateway_id = var.appgw_id
    }
    tags = var.tags

}

# User Workload Node pool (keep workloads in private subnet)

#resource "azurerm_kubernetes_cluster_node_pool" "usernp" {
#    name = "usernp"
#    kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
#    vm_size = var.user_vm_size
#    node_count = var.user_node_count
#    vnet_subnet_id = var.user_subnet_id
#    mode = "User"
#    orchestrator_version = var.kubenetes_version
#    tags = var.tags  
#}

