variable "location" {
    type = string
    description = "Azure Region where all resources will be provisioned"
    default = "East US"
}

variable "resource_group_name" {
    type = string 
    description = "This variable defines the resource group"
    default = "rg-azappsvc-1"
}

variable "svc_plan_name" {
    type = string 
    description = "This variable defines the app service plan"
    default = "svcplan-1"
}

variable "svc_plan_sku" {
    type = string 
    description = "This variable defines the app service plan SLU"
    default = "B2"
}

variable "app_name_prefix" {
    type= string
    default = "my-service-provider"
}

variable "storage_account_name" {
    type = string
    default = "samyappstorage1223"
}

variable "common_tags" {
    description = "Tags to apply to all resources"
    type = map(string)
    default = {
      "managedby" = "terraform"
    }
}

variable "vnet_name" {
    type = string
    default = "myvnet1223"
}

variable "subnet_name" {
    type = string
    default = "mysubnet1223"
}

variable "my_ip_address" {
    type = string
    description = "my current public IP address"
}