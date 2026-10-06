variable "resource_group_name" {
  type        = string
  description = "Name of the target Resource Group."
}

variable "location" {
  type        = string
  description = "Azure region for the ACR."
}

variable "acr_name" {
  type        = string
  description = "Name of the Azure Container Registry (must be globally unique, alphanumeric only)."
}

variable "sku" {
  type        = string
  default     = "Standard"
  description = "SKU for the Azure Container Registry (Basic, Standard, Premium)."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the ACR."
}