
variable "location" {
    type = string
}

variable "resource_group_name" {
    type = string
}

variable "subnet_id" {
    type = string
}

variable "appgw_name" {
    type = string
}

variable "sku_name" {
    type = string 
}

variable "min_capacity" {
    type = number
}

variable "tags" {
  type = map(string)
}
