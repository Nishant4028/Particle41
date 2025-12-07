 variable "location" {
   type = string
 }

 variable "resource_group_name" {
   type = string
 }

variable "aks_name" {
  type = string
}

variable "dns_prefix" {
  type = string

}

variable "service_cidr" {
  type = string
}

variable "dns_service_ip" {
  type = string
}

variable "network_plugin_mode" {
  type = string
}

variable "enable_private_cluster" {
  type = bool
}

variable "system_subnet_id" {
  type = string
}

variable "user_subnet_id" {
    type = string 
}

variable "system_vm_size" { 
    type = string 
}

variable "user_vm_size" { 
    type = string 
    
}

variable "user_node_count" {
    type = number
}

variable "system_node_count" {
    type = number
}

variable "appgw_id" {
    type = string
}

variable "tags" {
  type = map(string)
}