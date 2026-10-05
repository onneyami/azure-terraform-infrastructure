# Managed Identity used by the AKS Cluster
resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "id-aks-andrei"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = azurerm_resource_group.rg.tags
}

# Grant Network Contributor on the subnet so AKS can attach pods & load balancers
resource "azurerm_role_assignment" "aks_subnet_network_contributor" {
  scope                = azurerm_subnet.aks_subnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}