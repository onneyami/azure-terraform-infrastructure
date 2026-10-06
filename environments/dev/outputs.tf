output "resource_group_name" {
  value = data.azurerm_resource_group.rg.name
}

output "aks_cluster_name" {
  value = module.aks.cluster_name
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "connect_cluster_cmd" {
  value = "az aks get-credentials --resource-group ${data.azurerm_resource_group.rg.name} --name ${module.aks.cluster_name}"
}