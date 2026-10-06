variable "resource_group_name" {
  type        = string
  description = "Name of the target Resource Group."
}

variable "location" {
  type        = string
  description = "Azure region for the network resources."
}

variable "vnet_name" {
  type        = string
  default     = "vnet-andrei"
  description = "Name of the Virtual Network."
}

variable "vnet_address_space" {
  type        = list(string)
  default     = ["10.0.0.0/16"]
  description = "Address space for the Virtual Network."
}

variable "subnet_name" {
  type        = string
  default     = "snet-aks"
  description = "Name of the AKS Subnet."
}

variable "subnet_address_prefixes" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "Address prefixes for the AKS Subnet."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to network resources."
}