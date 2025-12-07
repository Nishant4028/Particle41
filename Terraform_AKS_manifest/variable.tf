variable "location" {
    description = "Azure Region"
    type = string
    default = "Eastus2"
}

variable "resource_group_name" {
    description = "Resource Group name"
    type = string
}

variable "vnet_address_space" {
    description = "CIDR for the Vnet"
    type = string
    default = "10.10.0.0/16"
}

variable "subnets" {

    description = "Map of subnet default"
    type = object({
      public_agw               = string 
      public_dmz               = string
      private_sys              = string
      private_user             = string
    })

    default = {
      public_agw               = "10.0.0.0/24"
      public_dmz               = "10.0.1.0/24"
      private_sys              = "10.0.2.0/24"
      private_user             = "10.0.3.0/24"
    } 
}

variable "aks_name" {
    description = "AKS cluster name"
    type = string
}



variable "dns_prefix" {
    type= string
    default = "aks"

}

variable "system_vm_size" {
    description = "VM size for system node pool"
    type = string
    default = "Standard_D2s_v3"
}

variable "user_vm_size" {
    description = "Vm size for user node pool"
    type = string
    default = "Standard_D4s_v5"
}

variable "system_node_count" {
    type = number
}

variable "user_node_count" {
    description = "Node count for user pool"
    default = 3
    type = number
}

variable "service_cidr" {
    description = "Kubernetes service CIDR"
    type = string
    default = "10.240.0.0/16"
}

variable "dns_service_ip" {
    description = "Kubernetes DNS service IP"
    type = string
    default = "overlay"

}
variable "network_plugin_mode" {
    description = "Azure CNI mode overlay"
    type = string
    default = "overlay"

  
}

variable "enable_private_cluster" {
  description = "Enable AKS private cluster"
  type = bool
  default = true
}



variable "appgw_name" {
    description = "Application gateway name"
    type = string
    default = "appgw-aks"
}

variable "appgw_sku" {
    description = "Application Gateway SKU"
    type = string
    default = "WAF_v2"
}

variable "appgw_min_capacity" {
    description = "App gateway autoscale min capacity"
    type =  number
    default = 2
}



variable "tags" {
    description = "Comman resource tags"
    type = map(string)
    default = {
      "env" = "dev"
    }
}

