variable "location" {
    type = string
}

variable "resource_group_name" {
    type = string
}

variable "vnet_address_space" {
    type = string 
}

variable "subnets" {
    type = object({
        public_agw               = string
        public_dmz               = string
        private_sys              = string
        private_user             = string
    })
}

variable "tags" {
    type = map(string)
}

