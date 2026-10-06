variable "resource_group_name" {
  type        = string
  description = "Name of the target Resource Group."
}

variable "location" {
  type        = string
  description = "Azure region for AKS."
}

variable "cluster_name" {
  type        = string
  default     = "aks-andrei"
  description = "Name of the AKS Cluster."
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where AKS nodes will be deployed."
}

variable "acr_id" {
  type        = string
  description = "ID of the ACR to attach AcrPull permissions to."
}

variable "node_count" {
  type        = number
  default     = 2
  description = "Initial node count for system pool."
}

variable "min_count" {
  type        = number
  default     = 1
  description = "Min auto-scaler count."
}

variable "max_count" {
  type        = number
  default     = 3
  description = "Max auto-scaler count."
}

variable "vm_size" {
  type        = string
  default     = "Standard_D2s_v5"
  description = "Virtual Machine size for cluster nodes."
}

variable "service_cidr" {
  type        = string
  default     = "10.2.0.0/16"
  description = "Kubernetes internal service CIDR (non-overlapping with VNet)."
}

variable "dns_service_ip" {
  type        = string
  default     = "10.2.0.10"
  description = "IP address within service_cidr for CoreDNS."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the cluster."
}