output "cluster_id" {
  value       = azurerm_kubernetes_cluster.aks.id
  description = "ID of the AKS Cluster."
}

output "cluster_name" {
  value       = azurerm_kubernetes_cluster.aks.name
  description = "Name of the AKS Cluster."
}

output "oidc_issuer_url" {
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  description = "OIDC Issuer URL for Workload Identity integration."
}