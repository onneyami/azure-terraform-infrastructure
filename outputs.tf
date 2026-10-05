output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "Target Resource Group Name"
}

output "aks_cluster_name" {
  value       = azurerm_kubernetes_cluster.aks.name
  description = "AKS Cluster Name"
}

output "acr_login_server" {
  value       = azurerm_container_registry.acr.login_server
  description = "Azure Container Registry URL"
}

output "connect_cluster_cmd" {
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.rg.name} --name ${azurerm_kubernetes_cluster.aks.name}"
  description = "Command to fetch kubeconfig credentials"
}