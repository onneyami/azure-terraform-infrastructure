variable "resource_group_name" {
  type        = string
  default     = "rg-andrei"
  description = "Name of the target Azure Resource Group."
}

variable "location" {
  type        = string
  default     = "westeurope"
  description = "Azure Region for all resources."
}

variable "cluster_name" {
  type        = string
  default     = "aks-andrei"
  description = "Name of the AKS cluster."
}

variable "acr_name" {
  type        = string
  default     = "crandreiaks2026" # Must be globally unique across Azure (letters/numbers only)
  description = "Name of the Azure Container Registry."
}