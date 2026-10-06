output "vnet_id" {
  value       = azurerm_virtual_network.vnet.id
  description = "ID of the Virtual Network."
}

output "vnet_name" {
  value       = azurerm_virtual_network.vnet.name
  description = "Name of the Virtual Network."
}

output "subnet_id" {
  value       = azurerm_subnet.aks_subnet.id
  description = "ID of the AKS Subnet."
}